/// A published phone contact with an open phone type.
///
/// The number and extension are kept as text without formatting changes.
///
/// ```swift
/// let voice = park.contacts?.phoneNumbers?.first { $0.type == "Voice" }
/// ```
public struct NPSPhoneNumber: Codable, Hashable, Sendable {
  /// The provider's explanatory text.
  public let description: String?

  /// The telephone extension as text.
  public let `extension`: String?

  /// The phone number without formatting changes.
  public let phoneNumber: String?

  /// The open type, including Voice, Fax, TTY, and future values.
  public let type: String?
}
