/// A photo gallery returned by the NPS photo galleries API.
///
/// Identity and title are required. Other documented fields are optional, preserving missing or
/// null values without substituting empty strings or arrays. ``images`` holds the provider's
/// preview image, not the gallery's contents; ``assetCount`` is the provider's count of the
/// gallery's assets. Unknown JSON fields are ignored by Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<PhotoGallery>.self, from: data)
/// for gallery in page.data {
///   print(gallery.title, gallery.assetCount ?? 0)
/// }
/// ```
public struct PhotoGallery: Codable, Hashable, Sendable {
  /// The provider's count of assets in the gallery.
  public let assetCount: Int?

  /// The provider's rights and usage constraints for the gallery.
  public let constraintsInfo: NPSConstraintsInfo?

  /// The provider's copyright text, kept as sent; upstream rights still apply.
  public let copyright: String?

  /// The provider's description of the gallery, including an empty string.
  public let description: String?

  /// The gallery identifier, preserved without UUID parsing.
  public let id: String

  /// Preview images in provider order, including an empty array.
  public let images: [NPSImage]?

  /// Parks NPS links to the gallery, including an empty array.
  public let relatedParks: [NPSRelatedPark]?

  /// Provider tags in the order sent, including an empty array.
  public let tags: [String]?

  /// The gallery's display title.
  public let title: String

  /// The gallery's web page URL text, not an API endpoint, kept as sent.
  public let url: String?
}
