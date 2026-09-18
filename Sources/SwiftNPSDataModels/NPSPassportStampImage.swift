/// An image of the National Parks Passport stamp available at a location.
///
/// Empty strings and arrays are preserved as sent. Upstream rights still apply.
///
/// ```swift
/// for stamp in campground.passportStampImages ?? [] {
///   print(stamp.altText ?? "")
/// }
/// ```
public struct NPSPassportStampImage: Codable, Hashable, Sendable {
  /// The alternative text, which often transcribes the stamp.
  public let altText: String?

  /// The original caption, including an empty string.
  public let caption: String?

  /// The attribution, including an empty string; upstream rights still apply.
  public let credit: String?

  /// Published crops, including an empty array, or nil when absent.
  public let crops: [NPSImageCrop]?

  /// The provider's description, including an empty string.
  public let description: String?

  /// The stamp image title.
  public let title: String?

  /// The image URL text, not an API endpoint.
  public let url: String?
}
