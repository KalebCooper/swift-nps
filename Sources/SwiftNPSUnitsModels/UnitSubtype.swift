#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A provider unit subtype with original identifiers and ordering.
public struct UnitSubtype: Codable, Hashable, Sendable {
  /// The provider's Code value, preserved without normalization.
  public let code: String
  /// The provider's Name value, preserved without normalization.
  public let name: String
  /// The provider's Units value, preserved without normalization.
  public let units: [UnitSummary]

  private enum CodingKeys: String, CodingKey {
    case code = "Code"
    case name = "Name"
    case units = "Units"
  }
}
