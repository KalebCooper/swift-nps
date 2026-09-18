/// A physical or mailing address with a provider-defined address type.
///
/// Parks and visitor centers publish addresses in this shape. Every field is optional and kept as
/// sent, including empty strings; postal and state codes are not validated.
///
/// ```swift
/// for address in park.addresses ?? [] where address.type == "Physical" {
///   print(address.line1 ?? "", address.city ?? "", address.stateCode ?? "")
/// }
/// ```
public struct NPSAddress: Codable, Hashable, Sendable {
  /// The city text.
  public let city: String?

  /// The country code, when supplied.
  public let countryCode: String?

  /// The first address line.
  public let line1: String?

  /// The second address line, including an empty string.
  public let line2: String?

  /// The third address line, including an empty string.
  public let line3: String?

  /// The postal code as text.
  public let postalCode: String?

  /// The province or territory code, when supplied.
  public let provinceTerritoryCode: String?

  /// The state code without interpretation.
  public let stateCode: String?

  /// The open address type, such as Physical or Mailing.
  public let type: String?
}
