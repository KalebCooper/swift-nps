/// A published email contact.
///
/// The address is kept exactly as published and is not validated.
///
/// ```swift
/// let email = park.contacts?.emailAddresses?.first?.emailAddress
/// ```
public struct NPSEmailAddress: Codable, Hashable, Sendable {
  /// The provider's explanatory text.
  public let description: String?

  /// The email address as published.
  public let emailAddress: String?
}
