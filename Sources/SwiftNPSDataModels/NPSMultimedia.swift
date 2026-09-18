/// A reference to provider multimedia with an open content type.
///
/// The link is kept as published text and is not an API endpoint.
///
/// ```swift
/// for media in park.multimedia ?? [] {
///   print(media.type ?? "", media.title ?? "")
/// }
/// ```
public struct NPSMultimedia: Codable, Hashable, Sendable {
  /// The provider identifier.
  public let id: String?

  /// The multimedia title.
  public let title: String?

  /// The provider's open media type.
  public let type: String?

  /// The original media link text.
  public let url: String?
}
