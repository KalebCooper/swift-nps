/// A published crop of an image.
///
/// The aspect ratio is the provider's number, and the link is kept as published text.
///
/// ```swift
/// for crop in image.crops ?? [] {
///   print(crop.aspectRatio ?? 0, crop.url ?? "")
/// }
/// ```
public struct NPSImageCrop: Codable, Hashable, Sendable {
  /// The width-to-height ratio as a number, when supplied.
  public let aspectRatio: Double?

  /// The cropped image URL text, not an API endpoint.
  public let url: String?
}
