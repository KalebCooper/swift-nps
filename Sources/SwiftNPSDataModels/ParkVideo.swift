/// A video returned by the NPS park videos API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. Accessibility flags are the
/// provider's JSON Booleans, and ``captionFiles`` lists the provider's caption tracks. ``versions``
/// lists the downloadable renditions, each with the provider's ``Version/fileSizeKb`` number.
/// Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<ParkVideo>.self, from: data)
/// for video in page.data {
///   print(video.title, video.versions?.first?.url ?? "")
/// }
/// ```
public struct ParkVideo: Codable, Hashable, Sendable {
  /// One caption track of a park video.
  ///
  /// ```swift
  /// for caption in video.captionFiles ?? [] {
  ///   print(caption.language ?? "", caption.url ?? "")
  /// }
  /// ```
  public struct CaptionFile: Codable, Hashable, Sendable {
    /// The provider's media type text, such as `"text/vtt"`, kept as an open string.
    public let fileType: String?

    /// The provider's language text, such as `"english"`, kept as an open string.
    public let language: String?

    /// The caption file's URL text, kept as sent.
    public let url: String?
  }

  /// One downloadable rendition of a park video.
  ///
  /// ```swift
  /// for version in video.versions ?? [] {
  ///   print(version.widthPixels ?? 0, version.heightPixels ?? 0, version.url ?? "")
  /// }
  /// ```
  public struct Version: Codable, Hashable, Sendable {
    /// The provider's width-to-height ratio as a JSON number, such as `1.778`.
    public let aspectRatio: Double?

    /// The provider's file size number, such as `15976.0`, or nil when the provider sends `null`.
    ///
    /// NPS documents no unit for this value, and it is kept as sent without conversion.
    public let fileSizeKb: Double?

    /// The provider's media type text, such as `"video/mp4"`, kept as an open string.
    public let fileType: String?

    /// The rendition's height in pixels.
    public let heightPixels: Int?

    /// The file's URL text, kept as sent.
    public let url: String?

    /// The rendition's width in pixels.
    public let widthPixels: Int?
  }

  /// The URL text of an American Sign Language version, including an empty string.
  public let aslVideoUrl: String?

  /// Whether the provider marks audio description as built into the video itself.
  public let audioDescribedBuiltIn: Bool?

  /// The provider's audio description text, including an empty string.
  public let audioDescription: String?

  /// The URL text of an audio-described version, including an empty string.
  public let audioDescriptionUrl: String?

  /// The provider's call to action text, including an empty string.
  public let callToAction: String?

  /// The call to action's URL text, including an empty string.
  public let callToActionUrl: String?

  /// Caption tracks in provider order, including an empty array.
  public let captionFiles: [CaptionFile]?

  /// The attribution, including an empty string; upstream rights still apply.
  public let credit: String?

  /// The provider's description of the video, including an empty string.
  public let description: String?

  /// The provider's descriptive transcript, including an empty string, kept as sent.
  public let descriptiveTranscript: String?

  /// The video's length in milliseconds, or nil when the provider sends `null`.
  public let durationMs: Int?

  /// The provider's geometry point-of-interest identifier, including an empty string.
  public let geometryPoiId: String?

  /// Whether the provider marks the video as carrying open captions.
  public let hasOpenCaptions: Bool?

  /// The video identifier, preserved without UUID parsing.
  public let id: String

  /// Whether the provider marks the video as B-roll footage.
  public let isBRoll: Bool?

  /// The provider's video-only flag, a JSON Boolean whose meaning NPS does not document.
  public let isVideoOnly: Bool?

  /// The latitude as a JSON number, or nil when the provider sends `null`.
  public let latitude: Double?

  /// The longitude as a JSON number, or nil when the provider sends `null`.
  public let longitude: Double?

  /// The video's web page URL text, not an API endpoint, kept as sent.
  public let permalinkUrl: String?

  /// Parks NPS links to the video, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// The image shown with the video; NPS sends only its URL text, which can be empty.
  public let splashImage: NPSImage?

  /// Provider tags in the order sent, including an empty array.
  public let tags: [String]?

  /// The video's display title.
  public let title: String

  /// The provider's transcript, including an empty string, kept as sent.
  public let transcript: String?

  /// Downloadable renditions in provider order, including an empty array.
  public let versions: [Version]?
}
