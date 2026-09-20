/// A webcam returned by the NPS webcams API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. ``isStreaming`` arrives as a JSON
/// Boolean and ``latitude`` and ``longitude`` as JSON numbers or `null`, and each keeps that type.
/// The API does not guarantee a per-camera location: several cameras in one park can share a
/// coordinate that describes the park rather than the camera, and it is kept as sent without
/// inference or correction. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<Webcam>.self, from: data)
/// for webcam in page.data where webcam.isStreaming == true {
///   print(webcam.title, webcam.status ?? "")
/// }
/// ```
public struct Webcam: Codable, Hashable, Sendable {
  /// The attribution, including an empty string; upstream rights still apply.
  public let credit: String?

  /// The provider's description of the view, including an empty string.
  public let description: String?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The webcam identifier, preserved without UUID parsing.
  public let id: String

  /// Image references and attribution, including an empty array, with URL text kept as sent.
  public let images: [NPSImage]?

  /// Whether the provider reports the webcam as streaming, decoded from a JSON Boolean.
  public let isStreaming: Bool?

  /// The latitude as a JSON number, or nil when the provider sends `null`.
  ///
  /// It is not guaranteed to locate this camera; cameras in one park can share one coordinate.
  public let latitude: Double?

  /// The longitude as a JSON number, or nil when the provider sends `null`.
  ///
  /// It is not guaranteed to locate this camera; cameras in one park can share one coordinate.
  public let longitude: Double?

  /// Parks NPS links to the webcam, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// The provider's status text, such as `"Active"` or `"Inactive"`, kept as an open string.
  public let status: String?

  /// The provider's status message, including an empty string.
  public let statusMessage: String?

  /// Provider tags in the order sent, including an empty array.
  public let tags: [String]?

  /// The webcam's display title.
  public let title: String

  /// The webcam's web page URL text, not an API endpoint.
  public let url: String?
}
