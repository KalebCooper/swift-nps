/// Rights and usage constraints NPS publishes for a photo gallery or gallery asset.
///
/// Both values are open provider text, such as `"Public domain"`, `"Unknown"`, or `"Full"`, and
/// are kept as sent. NPS does not publish a closed set, and this package does not interpret the
/// values; upstream rights still apply.
///
/// ```swift
/// if let constraints = gallery.constraintsInfo {
///   print(constraints.constraint ?? "", constraints.grantingRights ?? "")
/// }
/// ```
public struct NPSConstraintsInfo: Codable, Hashable, Sendable {
  /// The usage constraint text, such as `"Public domain"`.
  public let constraint: String?

  /// The rights grant text, such as `"Full"` or `"Unknown"`.
  public let grantingRights: String?
}
