/// An audio recording returned by the NPS park audio API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. ``transcript`` is the provider's text,
/// either plain text or HTML, unmodified. ``versions`` lists the downloadable files, each with the
/// provider's ``Version/fileSize`` number. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<ParkAudio>.self, from: data)
/// for audio in page.data {
///   print(audio.title, audio.versions?.first?.url ?? "")
/// }
/// ```
public struct ParkAudio: Codable, Hashable, Sendable {
  /// One downloadable file of a park audio recording.
  ///
  /// ```swift
  /// for version in audio.versions ?? [] {
  ///   print(version.fileType ?? "", version.url ?? "")
  /// }
  /// ```
  public struct Version: Codable, Hashable, Sendable {
    /// The provider's file size number, such as `170844.0`, which can be `0.0`.
    ///
    /// NPS documents no unit for this value, and it is kept as sent without conversion.
    public let fileSize: Double?

    /// The provider's media type text, such as `"audio/mp3"`, kept as an open string.
    public let fileType: String?

    /// The file's URL text, kept as sent.
    public let url: String?
  }

  /// The provider's call to action text, including an empty string.
  public let callToAction: String?

  /// The call to action's URL text, including an empty string.
  public let callToActionUrl: String?

  /// The attribution, including an empty string; upstream rights still apply.
  public let credit: String?

  /// The provider's description of the recording, including an empty string.
  public let description: String?

  /// The recording's length in milliseconds, or nil when the provider sends `null`.
  public let durationMs: Int?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// The audio identifier, preserved without UUID parsing.
  public let id: String

  /// The latitude as a JSON number, or nil when the provider sends `null`.
  public let latitude: Double?

  /// The longitude as a JSON number, or nil when the provider sends `null`.
  public let longitude: Double?

  /// The recording's web page URL text, not an API endpoint, kept as sent.
  public let permalinkUrl: String?

  /// Parks NPS links to the recording, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// The image shown with the recording; NPS sends only its URL text, which can be empty.
  public let splashImage: NPSImage?

  /// Provider tags in the order sent, including an empty array.
  public let tags: [String]?

  /// The recording's display title.
  public let title: String

  /// The provider's transcript, plain text or HTML such as `"<p>...</p>"`, kept as sent.
  public let transcript: String?

  /// Downloadable files in provider order, including an empty array.
  public let versions: [Version]?
}
