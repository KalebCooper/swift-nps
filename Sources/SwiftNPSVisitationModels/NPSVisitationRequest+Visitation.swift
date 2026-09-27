#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension NPSVisitationRequest where Response == [NPSVisitationRecord] {
  /// Requests the provider's national monthly records for a year.
  /// - Parameter year: A positive year.
  /// - Throws: `VisitationMonth.ValidationError.invalidYear` for a nonpositive year.
  public static func nationalVisitation(year: Int) throws(VisitationMonth.ValidationError) -> Self {
    Self(endpoint: try .nationalVisitation(year: year))
  }

  /// Requests one response without filling missing months or aggregating counts.
  /// - Parameter query: The validated unit codes and inclusive month range.
  public static func visitation(query: VisitationQuery) -> Self {
    Self(endpoint: .visitation(query: query))
  }
}
