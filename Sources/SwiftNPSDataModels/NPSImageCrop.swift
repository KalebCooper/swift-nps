/// A published crop of an image.
///
/// The provider sends the aspect ratio as a JSON number on some paths and as a JSON string on
/// others, and can mix both in one response. ``aspectRatio`` stores a string exactly as sent and
/// stores a number as its decimal text, so `1.00` becomes `"1.0"` and `"1.78"` stays `"1.78"`.
/// ``ratio`` parses that text when it is numeric. The link is kept as published text.
///
/// Encoding always writes ``aspectRatio`` as a JSON string. A crop decoded from the provider's JSON
/// number therefore does not encode back to the provider's wire shape, because the stored text
/// cannot record which form arrived and the type deliberately has no second property to hold it.
///
/// The same ratio can arrive as different text on different paths. `/thingstodo` sends the string
/// `"1"`, while `/visitorcenters` and `/campgrounds` send the number `1.00`, which is stored as
/// `"1.0"`. Those two crops are unequal values of this `Hashable` type even though they describe
/// one ratio, so compare or deduplicate crops across paths with ``ratio``, not ``aspectRatio``.
///
/// ```swift
/// for crop in image.crops ?? [] {
///   print(crop.aspectRatio ?? "", crop.ratio ?? 0, crop.url ?? "")
/// }
/// ```
public struct NPSImageCrop: Codable, Hashable, Sendable {
  private enum CodingKeys: String, CodingKey {
    case aspectRatio
    case url
  }

  /// The width-to-height ratio text: a string as sent, or a number's decimal text.
  public let aspectRatio: String?

  /// The cropped image URL text, not an API endpoint.
  public let url: String?

  /// The aspect ratio as a number, or nil when ``aspectRatio`` is absent or `Double.init(_:)`
  /// rejects its text.
  ///
  /// `Double.init(_:)` also accepts text such as `"inf"`, `"nan"`, and `"1e3"`, so a non-nil value
  /// is not guaranteed to be finite or a plausible ratio.
  public var ratio: Double? {
    aspectRatio.flatMap(Double.init)
  }

  /// Decodes a crop, accepting the aspect ratio as a JSON string, number, or null.
  ///
  /// - Parameter decoder: The decoder positioned at the crop object.
  /// - Throws: `DecodingError` when the object is malformed or the aspect ratio is neither a
  ///   string, a number, nor null.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    url = try container.decodeIfPresent(String.self, forKey: .url)
    do {
      aspectRatio = try container.decodeIfPresent(String.self, forKey: .aspectRatio)
    } catch DecodingError.typeMismatch {
      aspectRatio = try container.decode(Double.self, forKey: .aspectRatio).description
    }
  }
}
