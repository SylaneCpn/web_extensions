import 'dart:io';

import 'package:logging/logging.dart';
import 'package:web_extensions/web_extensions.dart';

final _jsReg = RegExp(r"^.+[.]js$");

Future<Result<(), UnknownDirectoryError>> cleanJSFiles(
  String path, {
  Logger? verbose,
}) async {
  late final Directory dir;
  verbose?.info("Deleting .js files in \"$path\"...");
  try {
    dir = .new(path);

    if (!await dir.exists()) {
      verbose?.info("\"${dir.path}\" doesn't exists : no need to cleanup!");
      return Ok(());
    }

    await for (final file in dir.list().where(
      (ent) =>
          FileSystemEntity.isFileSync(ent.path) && _jsReg.hasMatch(ent.path),
    )) {
      verbose?.info("Deleting \"$file\"...");
      await file.delete();
    }
  } catch (_) {
    verbose?.severe("No directory $path");
    return Err(UnknownDirectoryError(path));
  }
  return Ok(());
}
