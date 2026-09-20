/// An organization NPS links to a record.
///
/// Identifiers, names, and links are kept as sent, including empty strings. The link is
/// published text, not an API endpoint.
///
/// ```swift
/// for organization in organizations {
///   print(organization.name ?? "", organization.url ?? "")
/// }
/// ```
public struct NPSRelatedOrganization: Codable, Hashable, Sendable {
  /// The provider's organization identifier, including values unknown to this package.
  public let id: String?

  /// The organization name.
  public let name: String?

  /// The organization's web page URL text, not an API endpoint.
  public let url: String?
}
