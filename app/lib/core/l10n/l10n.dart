/// Localization configuration for the Recipe Planner app.
///
/// To generate localization files, add to pubspec.yaml:
/// ```yaml
/// flutter:
///   generate: true
/// ```
///
/// And create l10n.yaml at the project root:
/// ```yaml
/// arb-dir: lib/core/l10n
/// template-arb-file: app_en.arb
/// output-localization-file: app_localizations.dart
/// output-dir: lib/core/l10n/generated
/// ```
///
/// Then run: `flutter gen-l10n`
///
/// Usage in widgets:
/// ```dart
/// import 'package:recipe_planner/core/l10n/generated/app_localizations.dart';
///
/// Text(AppLocalizations.of(context)!.appTitle)
/// ```
library l10n;
