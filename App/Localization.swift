import Foundation
import SwiftUI

enum L10n {
  static func string(_ key: String.LocalizationValue) -> String {
    String(localized: key, table: "Localizable")
  }

  static func formatted(_ key: String, _ arguments: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: "Localizable", bundle: .main, comment: "")
    return String(format: format, locale: Locale.current, arguments: arguments)
  }

  static func key(_ key: String) -> LocalizedStringKey {
    LocalizedStringKey(key)
  }
}
