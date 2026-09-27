#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension SpeciesEndpoint {
  private static func encoded(_ value: String) -> String {
    value.utf8.map { byte in
      if (65...90).contains(byte) || (97...122).contains(byte) || (48...57).contains(byte)
        || [45, 46, 95, 126].contains(byte)
      {
        return String(UnicodeScalar(byte))
      }
      let digits = Array("0123456789ABCDEF")
      return "%" + String(digits[Int(byte >> 4)]) + String(digits[Int(byte & 15)])
    }.joined()
  }

  private static func list(_ route: String, query: SpeciesQuery) -> Self {
    let path =
      "/" + route + "/" + encoded(query.unitCode) + "/"
      + (query.categories?.map(encoded).joined(separator: ",") ?? "") + "?format=json"
    guard let endpoint = Self(path: path) else {
      preconditionFailure("Validated query values form a safe Species path.")
    }
    return endpoint
  }
}

extension SpeciesEndpoint where Response == [SpeciesItem] {
  /// Describes the provider's fulllist route.
  /// - Parameter query: Exact unit and optional categories.
  public static func species(query: SpeciesQuery) -> Self { list("fulllist", query: query) }
}

extension SpeciesEndpoint where Response == [SpeciesChecklistItem] {
  /// Describes the provider's checklist route.
  /// - Parameter query: Exact unit and optional categories.
  public static func speciesChecklist(query: SpeciesQuery) -> Self {
    list("checklist", query: query)
  }
}

extension SpeciesEndpoint where Response == [SpeciesDetailItem] {
  /// Describes the provider's detaillist route.
  /// - Parameter query: Exact unit and optional categories.
  public static func speciesDetails(query: SpeciesQuery) -> Self {
    list("detaillist", query: query)
  }
}
