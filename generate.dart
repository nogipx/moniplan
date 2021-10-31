import 'dart:io' as _i8;

import 'package:build_runner/build_runner.dart' as _i7;
import 'package:build_runner_core/build_runner_core.dart' as runner;
import 'package:build_config/src/input_set.dart';
import 'package:copy_with_extension_gen/builder.dart' as _i2;
import 'package:hive_generator/hive_generator.dart' as _i3;
import 'package:json_serializable/builder.dart' as _i4;
import 'package:source_gen/builder.dart' as _i5;

const domain = 'lib/sdk/domain';

const paths = [
  '$domain/operation/operation.dart',
];

final _builders = <runner.BuilderApplication>[
  runner.apply(
    r'copy_with_extension_gen:copy_with_extension_gen',
    [_i2.copyWith],
    runner.toDependentsOf(r'copy_with_extension_gen'),
    appliesBuilders: const [r'source_gen:combining_builder'],
    defaultGenerateFor: InputSet(include: paths),
  ),
  runner.apply(
    r'hive_generator:hive_generator',
    [_i3.getBuilder],
    runner.toDependentsOf(r'hive_generator'),
    appliesBuilders: const [r'source_gen:combining_builder'],
    defaultGenerateFor: InputSet(include: paths),
  ),
  runner.apply(
    r'json_serializable:json_serializable',
    [_i4.jsonSerializable],
    runner.toDependentsOf(r'json_serializable'),
    appliesBuilders: const [r'source_gen:combining_builder'],
    defaultGenerateFor: InputSet(include: paths),
  ),
  runner.apply(
    r'source_gen:combining_builder',
    [_i5.combiningBuilder],
    runner.toNoneByDefault(),
    hideOutput: false,
    appliesBuilders: const [r'source_gen:part_cleanup'],
  ),
  runner.applyPostProcess(
    r'source_gen:part_cleanup',
    _i5.partCleanup,
  )
];

Future<void> main() async {
  final result = await _i7.run(['build'], _builders);
  _i8.exitCode = result;
}
