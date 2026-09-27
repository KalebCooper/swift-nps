#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A bounded search with explicit code namespaces, submission and route-specific filters.
public enum TaxonSearch: Hashable, Sendable {
  /// Search a nonempty code list with an explicit namespace and submission method.
  case codes([String], kind: TaxonCodeKind, submission: TaxonomySubmission)
  /// Search common names; exact text is encoded without trimming or case folding.
  case commonName(String, category: String?, source: String?)
  /// Search scientific names, retaining the provider's search syntax.
  case scientificName(String, category: String?, source: String?)

  func components() throws(TaxonomyValidationError) -> (
    body: Data?, method: TaxonomyMethod, path: String, parameters: [(String, String)]
  ) {
    let category: String?
    let prefix: String
    let source: String?
    let text: String
    switch self {
    case .codes(let values, let kind, let submission):
      guard !values.isEmpty else { throw .invalidCode }
      var codes: [String] = []
      for value in values { codes.append(try TaxonomyEncoding.code(value)) }
      let body =
        submission == .post
        ? Data(("[" + codes.map { "\"" + $0 + "\"" }.joined(separator: ",") + "]").utf8) : nil
      return (
        body, submission == .post ? .post : .get, "/searchByCodes/" + kind.rawValue,
        submission == .get ? [("codes", codes.joined(separator: ","))] : []
      )
    case .commonName(let value, let filter, let classification):
      category = filter; prefix = "/searchByCommonName/"; source = classification; text = value
    case .scientificName(let value, let filter, let classification):
      category = filter; prefix = "/searchByScientificName/"; source = classification; text = value
    }
    let path = prefix + (try TaxonomyEncoding.component(text))
    var parameters: [(String, String)] = []
    if let category {
      try TaxonomyEncoding.validateText(category)
      parameters.append(("category", category))
    }
    if let source {
      try TaxonomyEncoding.validateText(source)
      parameters.append(("source", source))
    }
    return (nil, .get, path, parameters)
  }
}

enum TaxonomyEncoding {
  static func code(_ value: String) throws(TaxonomyValidationError) -> String {
    guard !value.isEmpty, value.utf8.allSatisfy({ (48...57).contains($0) }),
      let number = Int64(value), number > 0, number <= Int32.max
    else { throw .invalidCode }
    return value
  }

  static func component(_ value: String) throws(TaxonomyValidationError) -> String {
    try validateText(value)
    guard value != ".", value != "..", !value.contains("/"), !value.contains("\\"),
      !value.contains("%")
    else { throw .invalidSearchText }
    return encode(value)
  }

  static func encode(_ value: String) -> String {
    value.utf8.map { byte in
      switch byte {
      case 45, 46, 48...57, 65...90, 95, 97...122, 126: return String(UnicodeScalar(byte))
      default:
        let hex = String(byte, radix: 16, uppercase: true)
        return "%" + (hex.count == 1 ? "0" : "") + hex
      }
    }.joined()
  }

  static func query(_ parameters: [(String, String)]) -> String {
    parameters.sorted { $0.0 < $1.0 }.map { $0.0 + "=" + encode($0.1) }.joined(separator: "&")
  }

  static func validateText(_ value: String) throws(TaxonomyValidationError) {
    guard value.unicodeScalars.contains(where: { !$0.properties.isWhitespace }),
      !value.unicodeScalars.contains(where: { $0.value < 32 || $0.value == 127 })
    else { throw .invalidSearchText }
  }
}
