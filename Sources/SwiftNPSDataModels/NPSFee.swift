/// A published fee or pass, without numeric or currency conversion.
///
/// Parks use this shape for entrance fees and passes, and campgrounds use it for camping fees, as
/// the provider sends them. A fee does not imply reservation availability.
///
/// ```swift
/// for fee in park.entranceFees ?? [] {
///   print(fee.title ?? "", fee.cost ?? "")
/// }
/// ```
public struct NPSFee: Codable, Hashable, Sendable {
  /// The exact cost string; no currency is inferred.
  public let cost: String?

  /// The provider's fee or pass description.
  public let description: String?

  /// The fee or pass title.
  public let title: String?
}
