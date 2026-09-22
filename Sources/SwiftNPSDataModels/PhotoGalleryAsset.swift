/// A photo returned by the NPS photo gallery assets API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. The provider returns one entry per
/// gallery membership, so an asset in several galleries can appear more than once with the same
/// ``id`` and a different ``ordinal`` and ``permalinkUrl``; entries are not deduplicated. The entry
/// carries no gallery identifier field; only ``permalinkUrl`` names the gallery. Unknown JSON fields
/// are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<PhotoGalleryAsset>.self, from: data)
/// for asset in page.data {
///   print(asset.title, asset.fileInfo?.url ?? "")
/// }
/// ```
public struct PhotoGalleryAsset: Codable, Hashable, Sendable {
  /// The file NPS serves for a photo gallery asset.
  ///
  /// Every field is optional and kept as sent. ``fileSizeKb`` is the provider's number, for which
  /// NPS documents no unit.
  ///
  /// ```swift
  /// if let file = asset.fileInfo {
  ///   print(file.fileType ?? "", file.widthPixels ?? 0, file.heightPixels ?? 0)
  /// }
  /// ```
  public struct FileInfo: Codable, Hashable, Sendable {
    /// The provider's file size number, such as `5428193` for a 2736 by 3648 pixel `image/jpeg`.
    ///
    /// NPS documents no unit for this value, and it is kept as sent without conversion.
    public let fileSizeKb: Double?

    /// The provider's media type text, such as `"image/jpeg"`, kept as an open string.
    public let fileType: String?

    /// The file's height in pixels.
    public let heightPixels: Int?

    /// The file's URL text, kept as sent.
    public let url: String?

    /// The file's width in pixels.
    public let widthPixels: Int?
  }

  /// The provider's alternative text for the photo, including an empty string.
  public let altText: String?

  /// The provider's rights and usage constraints for the photo.
  public let constraintsInfo: NPSConstraintsInfo?

  /// The provider's copyright text, kept as sent; upstream rights still apply.
  public let copyright: String?

  /// The provider's credit text, including an empty string.
  public let credit: String?

  /// The provider's description of the photo, including an empty string.
  public let description: String?

  /// The file NPS serves for the photo.
  public let fileInfo: FileInfo?

  /// The asset identifier, preserved without UUID parsing and not unique within a page.
  public let id: String

  /// The provider's position of the photo within the gallery named by ``permalinkUrl``.
  public let ordinal: Int?

  /// The photo's web page URL text, not an API endpoint, kept as sent.
  public let permalinkUrl: String?

  /// Parks NPS links to the photo, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// Provider tags in the order sent, including an empty array.
  public let tags: [String]?

  /// The photo's display title.
  public let title: String
}
