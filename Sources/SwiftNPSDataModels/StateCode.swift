/// A two-letter state or territory code used in a parks query.
///
/// Accepts ASCII letters without a closed catalog. Case is preserved and no whitespace is trimmed.
/// NPS decides whether a syntactically valid code matches a park.
///
/// ```swift
/// let code = try StateCode("ME")
/// ```
public struct StateCode: Hashable, Sendable {
  /// Why a state code cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The code does not contain exactly two ASCII letters.
    case invalidValue
  }

  /// The caller's exact code.
  public let rawValue: String

  /// Validates a state code without contacting NPS.
  /// - Parameter rawValue: A two-letter code such as `ME`.
  /// - Throws: ``ValidationError/invalidValue`` for invalid syntax.
  public init(_ rawValue: String) throws(ValidationError) {
    guard rawValue.utf8.count == 2,
      rawValue.utf8.allSatisfy({ (65...90).contains($0) || (97...122).contains($0) })
    else { throw .invalidValue }
    self.rawValue = rawValue
  }
}
