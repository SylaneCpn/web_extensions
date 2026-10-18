import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:web_extensions/web_extensions.dart';

class AppCommandRunner extends CommandRunner {
  AppCommandRunner(super.executableName, super.description) {
    configureLogger();
    addCommand(BuildCommand());
  }
}

class BuildCommand extends Command<void> {
  BuildCommand() {
    buildParser();
  }

  @override
  String get description => 'Compiles dart files to javascript.';

  @override
  String get name => 'build';

  @override
  void printUsage() {
    print('Usage: dart web_extensions build <flags> [arguments]');
    print(argParser.usage);
  }

  @override
  Future<void> run() async {
    try {
      Logger? verbose;
      final srcDir = argResults!.option('source-dir')!;
      final outDir = argResults!.option('dest-dir')!;

      if (argResults!.flag('help')) {
        printUsage();
        return;
      }

      if (argResults!.flag('verbose')) {
        verbose = Logger.root;
      }

      // Act on the arguments provided.
      verbose?.info('Positional arguments: ${argResults!.rest}');

      verbose?.info('[VERBOSE] All arguments: ${argResults!.arguments}');
      if (argResults!.flag('cleanup')) {
        if (await cleanJSFiles(outDir, verbose: verbose) case Err(
          :final error,
        )) {
          print("[ERROR] : Could not find directory ${error.path}.");
          print("Aborting.");
          return;
        }
      }

      if (await compileToJS(
            sourceDir: srcDir,
            destDir: outDir,
            verbose: verbose,
          )
          case Err(:final error)) {
        print("[ERROR] : Could not find directory ${error.path}.");
        print("Aborting.");
        return;
      }

      if (await cleanDepsFiles(outDir, verbose: verbose) case Err(
        :final error,
      )) {
        print("[ERROR] : Could not find directory ${error.path}.");
        print("Aborting.");
        return;
      }

      verbose?.info("All done !");
    } on FormatException catch (e) {
      // Print usage information if an invalid argument was provided.
      print(e.message);
      print('');
      printUsage();
    }
  }

  void buildParser() {
    argParser
      // ..addFlag(
      //   'help',
      //   abbr: 'h',
      //   negatable: false,
      //   help: 'Print this usage information.',
      // )
      ..addFlag(
        'verbose',
        abbr: 'v',
        negatable: false,
        help: 'Show additional command output.',
      )
      ..addFlag('version', negatable: false, help: 'Print the tool version.')
      ..addOption(
        'source-dir',
        abbr: 's',
        defaultsTo: './targetJs',
        help: 'Specifies the dart source files directory.',
      )
      ..addFlag(
        'cleanup',
        abbr: 'c',
        defaultsTo: true,
        help: "Cleanup previous .js files in the destination directory before compiling ",
      )
      ..addOption(
        'dest-dir',
        abbr: 'd',
        defaultsTo: './${getDirectoryName(Directory.current)}',
        help: 'Specifies the directory where the compiled files will be put.',
      );
  }
}
