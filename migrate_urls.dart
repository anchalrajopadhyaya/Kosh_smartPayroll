import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print('lib directory not found');
    return;
  }

  final files = dir.listSync(recursive: true);
  int count = 0;

  for (final file in files) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = file.readAsStringSync();
      if (content.contains('10.0.2.2:3000')) {
        print('Migrating ${file.path}...');
        var newContent = content;

        // 1. Replace Uri.parse('http://10.0.2.2:3000/path') -> AppConfig.apiUri('/path')
        newContent = newContent.replaceAllMapped(
          RegExp(
            r"Uri\.parse\(['\u0022]http://10\.0\.2\.2:3000([^'\u0022]*)['\u0022]\)",
          ),
          (match) {
            final path = match.group(1) ?? '';
            return "AppConfig.apiUri('$path')";
          },
        );

        // 2. Replace 'http://10.0.2.2:3000/path' -> '${AppConfig.baseUrl}/path'
        newContent = newContent.replaceAllMapped(
          RegExp(r"['\u0022]http://10\.0\.2\.2:3000([^'\u0022]*)['\u0022]"),
          (match) {
            final path = match.group(1) ?? '';
            return "'\${AppConfig.baseUrl}$path'";
          },
        );

        // 3. Insert config.dart import at the top if not already present
        if (!newContent.contains(
              'import \'package:payroll/frontend/utils/config.dart\';',
            ) &&
            !newContent.contains(
              'import "package:payroll/frontend/utils/config.dart";',
            )) {
          newContent =
              "import 'package:payroll/frontend/utils/config.dart';\n$newContent";
        }

        file.writeAsStringSync(newContent);
        count++;
      }
    }
  }

  print('Migration completed! Updated $count files.');
}
