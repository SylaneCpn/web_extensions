import 'package:logging/logging.dart';

export './src/types.dart';
export './src/clean_js.dart';
export './src/utils.dart';
export './src/compile_to_js.dart';
export './src/clean_deps_files.dart';
export './src/cli.dart';

void configureLogger() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}
