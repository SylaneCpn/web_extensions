import 'dart:io';

import 'package:logging/logging.dart';
import 'package:web_extensions/web_extensions.dart';

final _depsReg = RegExp(r"^.+[.]deps$");

Future<Result<(), UnknownDirectoryError>> cleanDepsFiles(
  String path, {
  Logger? verbose,
}) async {
  late final Directory dir;
  verbose?.info("Deleting .deps files in $path...");
  try {
    dir = .new(path);
  } catch (_) {
    verbose?.severe("No directory $path");
    return Err(UnknownDirectoryError(path));
  }

  await for (final depsFile in dir.list().where(
    (ent) =>
        FileSystemEntity.isFileSync(ent.path) && _depsReg.hasMatch(ent.path),
  )) {
    verbose?.info("Deleting ${depsFile.path}...");
    await depsFile.delete();
  }
  return Ok(());
}
