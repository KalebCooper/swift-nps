#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A provider unit summary with original identifiers and ordering.
public struct UnitSummary: Codable, Hashable, Sendable {
  /// The provider's Code value, preserved without normalization.
  public let code: String
  /// The provider's Name value, preserved without normalization.
  public let name: String

  private enum CodingKeys: String, CodingKey {
    case code = "Code"
    case name = "Name"
  }
}
