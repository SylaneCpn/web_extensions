import 'dart:io';

import 'package:logging/logging.dart';
import 'package:web_extensions/web_extensions.dart';

final _dartReg = RegExp(r"^.+[.]dart$");

Future<Result<(), UnknownDirectoryError>> compileToJS({
  required String sourceDir,
  required String destDir,
  Logger? verbose,
}) async {
  final Directory sources = .new(sourceDir)..createSync();
  final Directory destination = .new(destDir);

  verbose?.info("Compiling .dart files in $sourceDir to $destDir...");

  try {
    await for (final source in sources.list().where(
      (ent) =>
          FileSystemEntity.isFileSync(ent.path) && _dartReg.hasMatch(ent.path),
    )) {
      final fileName = extractFileNameFromPath(File(source.path));

      final newFilePath =
          "${destination.path}/${fileName.replaceAll(".dart", ".js")}";

      verbose?.info("Compiling ${source.path} to $newFilePath...");
      await Process.run("dart", [
        "compile",
        "js",
        source.path,
        "-o",
        newFilePath,
        "--no-source-maps",
      ]);
    }
  } on PathNotFoundException catch (e) {
    verbose?.severe("No directory ${e.path}");
    return Err(UnknownDirectoryError(e.path!));
  }
  return Ok(());
}
