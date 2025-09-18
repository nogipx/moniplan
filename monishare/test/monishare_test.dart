import 'dart:async';

import 'package:monishare/models.dart';
import 'package:monishare/monishare_client.dart';
import 'package:monishare/monishare_responder.dart';
import 'package:rpc_dart/rpc_dart.dart';
import 'package:test/test.dart';

void main() {
  late RpcCallerEndpoint caller;
  late RpcResponderEndpoint responder;
  late MoniShareClient client;
  late IRpcTransport clientTransport;
  late IRpcTransport serverTransport;

  setUp(() {
    final pair = RpcInMemoryTransport.pair();
    clientTransport = pair.$1;
    serverTransport = pair.$2;

    caller = RpcCallerEndpoint(transport: clientTransport);
    responder = RpcResponderEndpoint(transport: serverTransport);

    final service = MoniShareResponder();
    responder.registerServiceContract(service);

    responder.start();
    caller.start();

    client = MoniShareClient(caller);
  });

  tearDown(() async {
    await caller.close();
    await responder.close();
  });

  OperationPayload buildPayload(String actor, String ciphertext) {
    return OperationPayload(
      actorPseudoId: actor,
      cipherLen: ciphertext.length,
      cipherHash: 'hash-$ciphertext',
      ciphertextB64: ciphertext,
    );
  }

  Future<void> waitForStreamSetup() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  Future<void> cancelSafely(StreamSubscription<dynamic> subscription) async {
    try {
      await subscription.cancel().timeout(const Duration(milliseconds: 100));
    } on TimeoutException {
      // Ignore cancellation timeouts in tests.
    }
  }

  group('MoniShare responder', () {
    test('Append/Pull/Subscribe (single client)', () async {
      final space = await client.spacesRegister();
      final spaceId = space.space.plannerSpaceId;

      final completer1 = Completer<OpsNotification>();
      final completer2 = Completer<OpsNotification>();
      final subscription = client.opsSubscribe(plannerSpaceId: spaceId).listen(
        (event) {
          if (!completer1.isCompleted) {
            completer1.complete(event);
          } else if (!completer2.isCompleted) {
            completer2.complete(event);
          }
        },
      );

      await waitForStreamSetup();

      await client.opsAppend(
        plannerSpaceId: spaceId,
        operations: [buildPayload('actor-a', 'cipher-a')],
      );
      final first = await completer1.future;
      expect(first.lastOpIdx, 1);
      expect(first.batchSize, 1);

      await client.opsAppend(
        plannerSpaceId: spaceId,
        operations: [buildPayload('actor-a', 'cipher-b')],
      );
      final second = await completer2.future;
      expect(second.lastOpIdx, 2);

      await cancelSafely(subscription);

      final pull = await client.opsPull(
        plannerSpaceId: spaceId,
        sinceOpIdx: 0,
      );

      expect(pull.operations.map((op) => op.opIdx), [1, 2]);
      expect(
          pull.operations.every((op) => op.plannerSpaceId == spaceId), isTrue);
    });

    test('Two clients collaborate via subscribe and pull', () async {
      final ownerClient = client;
      final joinerClient = client;
      final space = await ownerClient.spacesRegister();
      final spaceId = space.space.plannerSpaceId;

      final notificationCompleter = Completer<OpsNotification>();
      final subscription =
          joinerClient.opsSubscribe(plannerSpaceId: spaceId).listen((event) {
        if (!notificationCompleter.isCompleted) {
          notificationCompleter.complete(event);
        }
      });

      await waitForStreamSetup();

      await ownerClient.opsAppend(
        plannerSpaceId: spaceId,
        operations: [
          buildPayload('actor-a', 'cipher-1'),
          buildPayload('actor-a', 'cipher-2'),
        ],
      );

      final notification = await notificationCompleter.future;
      expect(notification.batchSize, 2);
      expect(notification.lastOpIdx, 2);

      final pullResult = await joinerClient.opsPull(
        plannerSpaceId: spaceId,
        sinceOpIdx: 0,
      );

      expect(pullResult.operations.length, 2);
      expect(pullResult.operations.last.opIdx, 2);

      await cancelSafely(subscription);
    });

    test('Invite lifecycle create/respond/finalize/fetch', () async {
      final space = await client.spacesRegister();
      final spaceId = space.space.plannerSpaceId;

      final created = await client.invitesCreate(
        plannerSpaceId: spaceId,
        ownerHandshakeB64: 'handshake-owner',
        ttlSeconds: 60,
      );

      final inviteId = created.invite.inviteId;
      expect(created.invite.state, InviteState.created);
      expect(created.invite.ownerHandshakeB64, 'handshake-owner');

      final responded = await client.invitesRespond(
        inviteId: inviteId,
        joinerHandshakeB64: 'handshake-joiner',
      );

      expect(responded.invite.state, InviteState.responded);
      expect(responded.invite.joinerHandshakeB64, 'handshake-joiner');

      final finalized = await client.invitesFinalize(
        inviteId: inviteId,
        finalHandshakeB64: 'handshake-final',
        encryptedEnvelopeB64: 'encrypted-envelope',
      );

      expect(finalized.invite.state, InviteState.finalized);
      expect(finalized.invite.finalHandshakeB64, 'handshake-final');
      expect(finalized.invite.encryptedEnvelopeB64, 'encrypted-envelope');

      final fetched = await client.invitesFetch(inviteId: inviteId);
      expect(fetched.invite, isNotNull);
      expect(fetched.invite!.state, InviteState.finalized);
      expect(fetched.invite!.encryptedEnvelopeB64, 'encrypted-envelope');
    });

    test('Archived space rejects append operations', () async {
      final space = await client.spacesRegister();
      final spaceId = space.space.plannerSpaceId;

      await client.spacesArchive(plannerSpaceId: spaceId);

      expect(
        () => client.opsAppend(
          plannerSpaceId: spaceId,
          operations: [buildPayload('actor-a', 'cipher-x')],
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('space_archived'),
          ),
        ),
      );
    });

    test('Offline catch-up delivers all operations after given index',
        () async {
      final space = await client.spacesRegister();
      final spaceId = space.space.plannerSpaceId;

      for (var i = 0; i < 100; i++) {
        await client.opsAppend(
          plannerSpaceId: spaceId,
          operations: [
            buildPayload('actor-a', 'cipher-$i'),
          ],
        );
      }

      final pullResult = await client.opsPull(
        plannerSpaceId: spaceId,
        sinceOpIdx: 60,
      );

      expect(pullResult.operations.length, 40);
      expect(pullResult.operations.first.opIdx, 61);
      expect(pullResult.operations.last.opIdx, 100);

      final notificationCompleter = Completer<OpsNotification>();
      final subscription =
          client.opsSubscribe(plannerSpaceId: spaceId).listen((event) {
        if (!notificationCompleter.isCompleted) {
          notificationCompleter.complete(event);
        }
      });

      await waitForStreamSetup();

      await client.opsAppend(
        plannerSpaceId: spaceId,
        operations: [buildPayload('actor-a', 'cipher-101')],
      );
      final notification = await notificationCompleter.future;
      expect(notification.lastOpIdx, 101);

      await cancelSafely(subscription);
    });
  });
}
