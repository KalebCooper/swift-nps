#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension VisitationEndpoint where Response == [NPSVisitationRecord] {
  /// Describes national monthly records for a positive year.
  /// - Parameter year: The year to request; months are not aggregated.
  /// - Throws: `VisitationMonth.ValidationError.invalidYear` for a nonpositive year.
  public static func nationalVisitation(year: Int) throws(VisitationMonth.ValidationError) -> Self {
    guard year > 0 else { throw .invalidYear }
    guard let endpoint = Self(path: "/total/\(year)?format=json") else {
      preconditionFailure("A positive integer produces a valid statistics path.")
    }
    return endpoint
  }

  /// Describes one response for the validated unit and month range.
  /// - Parameter query: Codes and inclusive months to serialize in parameter-name order.
  public static func visitation(query: VisitationQuery) -> Self {
    let codes = query.unitCodes.map { code in
      code.utf8.map { byte in
        if (65...90).contains(byte) || (97...122).contains(byte) || (48...57).contains(byte)
          || [45, 46, 95, 126].contains(byte)
        {
          return String(UnicodeScalar(byte))
        }
        let hex = String(byte, radix: 16, uppercase: true)
        return "%" + (hex.count == 1 ? "0" : "") + hex
      }.joined()
    }.joined(separator: ",")
    let path =
      "/visitation?endMonth=\(query.end.month)&endYear=\(query.end.year)&format=json"
      + "&startMonth=\(query.start.month)&startYear=\(query.start.year)&unitCodes=\(codes)"
    guard let endpoint = Self(path: path) else {
      preconditionFailure("Validated inputs and encoded query values produce a statistics path.")
    }
    return endpoint
  }
}
