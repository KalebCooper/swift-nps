#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Exact unit and optional ordered categories for one whole-list response.
public struct SpeciesQuery: Hashable, Sendable {
  /// A local input cannot be serialized as a safe single path component.
  public enum ValidationError: Error, Hashable, Sendable {
    /// Supply at least one category or omit the list.
    case emptyCategories
    /// A component is empty or contains whitespace or ambiguous path syntax.
    case invalidPathComponent
  }
  /// Exact category strings in requested order; nil omits the segment.
  public let categories: [String]?
  /// Exact administrative code, independent of Data API ParkCode.
  public let unitCode: String

  /// Creates one list query without trimming or normalizing input.
  /// - Parameters:
  ///   - categories: Optional nonempty list. Commas delimit entries on the wire.
  ///   - unitCode: One safe unit code.
  /// - Throws: ValidationError for empty lists or unsafe components.
  public init(categories: [String]? = nil, unitCode: String) throws(ValidationError) {
    guard categories?.isEmpty != true else { throw .emptyCategories }
    for value in [unitCode] + (categories ?? []) {
      guard !value.isEmpty, value != ".", value != "..",
        !value.contains(where: { ",/%\\".contains($0) }),
        !value.unicodeScalars.contains(where: {
          $0.properties.isWhitespace || $0.value < 32 || $0.value == 127
        })
      else { throw .invalidPathComponent }
    }
    self.categories = categories
    self.unitCode = unitCode
  }
}
