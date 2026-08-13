import Foundation

/// User-facing text.
///
/// The English string is the key. Translations live in
/// `Resources/<language>.lproj/Localizable.strings` and macOS picks one
/// automatically from the user's preferred languages, so nothing has to be
/// configured in the app. Adding a language means adding one more .lproj
/// folder; missing keys fall back to the English key itself.
func L(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

func L(_ key: String, _ arguments: CVarArg...) -> String {
    String(format: NSLocalizedString(key, comment: ""), arguments: arguments)
}
