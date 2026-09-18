/// An identifier sent as a query filter, without a closed catalog or a format check.
///
/// NPS identifiers are usually uppercase UUIDs, but the value is otherwise open: any nonempty
/// text without whitespace or control characters is accepted. Case is preserved, and no trimming
/// or normalization is performed. NPS decides whether an identifier matches a resource. Response
/// identifiers remain plain strings.
///
/// ```swift
/// let identifier = try NPSIdentifier("C54D2783-6F50-4E03-9010-FCDA5C31EE91")
/// ```
public struct NPSIdentifier: Hashable, Sendable {
  /// Why an identifier cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The value is empty or contains whitespace or control characters.
    case invalidValue
  }

  /// The caller's exact identifier.
  public let rawValue: String

  /// Validates an identifier without contacting NPS.
  /// - Parameter rawValue: A nonempty identifier such as a thing to do UUID.
  /// - Throws: ``ValidationError/invalidValue`` for empty text or text containing whitespace or
  ///   control characters.
  public init(_ rawValue: String) throws(ValidationError) {
    guard !rawValue.isEmpty,
      rawValue.unicodeScalars.allSatisfy({
        !$0.properties.isWhitespace && $0.properties.generalCategory != .control
      })
    else { throw .invalidValue }
    self.rawValue = rawValue
  }
}
