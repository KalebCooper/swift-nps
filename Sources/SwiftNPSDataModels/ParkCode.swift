/// A single park code accepted by a lookup, without a closed catalog of known parks.
///
/// Codes contain 4 through 10 ASCII letters or digits. Case is preserved; no trimming or
/// normalization is performed. Response identifiers remain plain strings.
///
/// ```swift
/// let code = try ParkCode("acad")
/// ```
public struct ParkCode: Hashable, Sendable {
  /// Why a lookup code could not be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The value is not 4 through 10 ASCII letters or digits.
    case invalidValue
  }

  /// The exact code supplied by the caller.
  public let rawValue: String

  /// Validates a single code without contacting NPS.
  /// - Parameter rawValue: A code such as `acad`, including codes unknown to this package.
  /// - Throws: ``ValidationError/invalidValue`` for invalid syntax.
  public init(_ rawValue: String) throws(ValidationError) {
    guard (4...10).contains(rawValue.utf8.count),
      rawValue.utf8.allSatisfy({
        (48...57).contains($0) || (65...90).contains($0) || (97...122).contains($0)
      })
    else { throw .invalidValue }
    self.rawValue = rawValue
  }
}
