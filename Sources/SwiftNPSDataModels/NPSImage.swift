/// An image reference with attribution, accessibility text, and published crops.
///
/// Links are kept as published text and are not API endpoints. Upstream rights still apply.
///
/// ```swift
/// for image in center.images ?? [] {
///   print(image.title ?? "", image.crops?.count ?? 0)
/// }
/// ```
public struct NPSImage: Codable, Hashable, Sendable {
  /// The alternative text.
  public let altText: String?

  /// The original caption.
  public let caption: String?

  /// The attribution; upstream rights still apply.
  public let credit: String?

  /// Published crops, including an empty array, or nil when absent.
  public let crops: [NPSImageCrop]?

  /// The image title.
  public let title: String?

  /// The image URL text, not an API endpoint.
  public let url: String?
}
