/// Contact information published for a park or visitor center.
///
/// Missing arrays decode to nil, separately from the empty arrays NPS sends when it publishes no
/// contacts of a kind.
///
/// ```swift
/// for phone in park.contacts?.phoneNumbers ?? [] {
///   print(phone.type ?? "", phone.phoneNumber ?? "")
/// }
/// ```
public struct NPSContacts: Codable, Hashable, Sendable {
  /// Published email contacts, or nil when unavailable.
  public let emailAddresses: [NPSEmailAddress]?

  /// Published phone contacts, or nil when unavailable.
  public let phoneNumbers: [NPSPhoneNumber]?
}
