/// An image reference with attribution, accessibility text, and published crops.
///
/// Every NPS image object is a variant of this shape: some paths omit `crops` or `description`,
/// and each missing key decodes to nil. Empty strings and arrays are preserved as sent. Links are
/// kept as published text and are not API endpoints. Upstream rights still apply.
///
/// ```swift
/// for image in center.images ?? [] {
///   print(image.title ?? "", image.description ?? "", image.crops?.count ?? 0)
/// }
/// ```
public struct NPSImage: Codable, Hashable, Sendable {
  /// The alternative text, which often transcribes a passport stamp.
  public let altText: String?

  /// The original caption, including an empty string.
  public let caption: String?

  /// The attribution, including an empty string; upstream rights still apply.
  public let credit: String?

  /// Published crops, including an empty array, or nil when absent.
  public let crops: [NPSImageCrop]?

  /// The provider's description, including an empty string, or nil when absent.
  public let description: String?

  /// The image title.
  public let title: String?

  /// The image URL text, not an API endpoint.
  public let url: String?
}
