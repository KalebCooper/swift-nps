#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// One provider-reported month of recreational and nonrecreational visits.
///
/// National records retain nil unit identifiers. Missing months are not zero counts.
public struct NPSVisitationRecord: Codable, Hashable, Sendable {
  /// The provider's month number, retained without calendar validation.
  public let month: Int
  /// The reported nonrecreational visit count.
  public let nonRecreationVisitors: Int64
  /// The reported recreational visit count.
  public let recreationVisitors: Int64
  /// The exact unit code, or nil for national totals.
  public let unitCode: String?
  /// The provider's unit name, or nil for national totals.
  public let unitName: String?
  /// The provider's year.
  public let year: Int

  private enum CodingKeys: String, CodingKey {
    case month = "Month"
    case nonRecreationVisitors = "NonRecreationVisitors"
    case recreationVisitors = "RecreationVisitors"
    case unitCode = "UnitCode"
    case unitName = "UnitName"
    case year = "Year"
  }
}
