/// A labeled fact NPS publishes about a place or person.
///
/// The identifier names the kind of fact, such as a birthplace, not the row it appears in, so
/// several records can share one `id`. Values are kept as sent, including empty strings.
///
/// ```swift
/// for fact in facts {
///   print(fact.name ?? "", fact.value ?? "")
/// }
/// ```
public struct NPSQuickFact: Codable, Hashable, Sendable {
  /// The fact type identifier, shared across records that publish the same kind of fact.
  public let id: String?

  /// The provider's label, such as `"Significance"`.
  public let name: String?

  /// The fact text as sent, which may contain HTML.
  public let value: String?
}
