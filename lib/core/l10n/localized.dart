import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/presentation/providers/language_provider.dart';

/// Single sanctioned picker for English/Hinglish vs Hindi content fields (AM-60).
///
/// When [lang] is `hi` and [hi] is non-empty, returns [hi]; otherwise [en].
/// Hindi DB columns are nullable — always pass the English field.
///
/// Prefer [localized] from a `ConsumerWidget` / `ConsumerState` `build` method.
/// Use [localizedLang] when you already have a language code (child widgets,
/// tests, or a screen that watched [languageProvider] once).
String localizedLang(String lang, {required String en, String? hi}) {
  if (lang == 'hi') {
    final h = hi;
    if (h != null && h.isNotEmpty) return h;
  }
  return en;
}

/// Watches [languageProvider] and applies [localizedLang].
/// Call from `build` — do not call from `initState`.
String localized(WidgetRef ref, {required String en, String? hi}) {
  return localizedLang(ref.watch(languageProvider), en: en, hi: hi);
}
