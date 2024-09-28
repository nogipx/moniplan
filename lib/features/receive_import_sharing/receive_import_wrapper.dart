import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan/features/receive_import_sharing/bloc/_index.dart';

class ReceiveImportWrapper extends StatelessWidget {
  final Widget child;

  const ReceiveImportWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiveImportSharingBloc, ReceiveImportState>(
      child: child,
      listenWhen: (prev, curr) {
        return curr is ReceiveImportDecisionState || curr is ReceiveImportResultState;
      },
      listener: (context, state) async {
        if (state is ReceiveImportDecisionState) {
          final decision = await _onDataReceived(context, state);
          if (decision != null) {
            context.read<ReceiveImportSharingBloc>().add(decision);
          }
        }
        if (state is ReceiveImportResultState) {
          _onImported(context, state);
        }
      },
    );
  }

  Future<ReceiveImportOnDecisionEvent?> _onDataReceived(
    BuildContext context,
    ReceiveImportDecisionState state,
  ) async {
    if (!context.mounted) {
      return null;
    }

    final backup = state.toImportBackups.first;

    final shouldImport = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Text('Is this backup should be imported?'),
            const SizedBox(height: 16),
            Visibility(
              visible: backup.creationDate != null,
              child: Text('Created at ${backup.creationDate}'),
            ),
            const SizedBox(height: 8),
            Visibility(
              visible: backup.plannersCount > 0,
              child: Text('Has ${backup.plannersCount} planners'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes, import it'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );

    return ReceiveImportOnDecisionEvent(
      shouldImport: shouldImport ?? false,
      acceptedBackup: backup,
    );
  }

  Future<void> _onImported(BuildContext context, ReceiveImportResultState state) async {
    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Text('Backup Imported'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Good'),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
