#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// An inclusive month range and ordered unit codes for a single visitation response.
public struct VisitationQuery: Hashable, Sendable {
  /// Invalid local range or list syntax.
  public enum ValidationError: Error, Hashable, Sendable {
    /// At least one unit code is required.
    case emptyUnits
    /// A code is empty or contains whitespace, controls, or a comma delimiter.
    case invalidUnitCode
    /// The start follows the end.
    case reversedRange
  }

  /// The inclusive final month.
  public let end: VisitationMonth
  /// The inclusive initial month.
  public let start: VisitationMonth
  /// Exact codes in caller order, including any repeated codes.
  public let unitCodes: [String]

  /// Creates a query without trimming, case conversion, or network access.
  /// - Parameters:
  ///   - end: The inclusive last month.
  ///   - start: The inclusive first month.
  ///   - unitCodes: Nonempty codes, without list delimiters or whitespace.
  /// - Throws: A validation error before any request is sent.
  public init(end: VisitationMonth, start: VisitationMonth, unitCodes: [String])
    throws(ValidationError)
  {
    guard !unitCodes.isEmpty else { throw .emptyUnits }
    guard
      unitCodes.allSatisfy({ code in
        !code.isEmpty && !code.contains(",") && !code.contains(where: \.isWhitespace)
          && !code.unicodeScalars.contains(where: { $0.value < 32 || $0.value == 127 })
      })
    else { throw .invalidUnitCode }
    guard start.year < end.year || (start.year == end.year && start.month <= end.month) else {
      throw .reversedRange
    }
    self.end = end
    self.start = start
    self.unitCodes = unitCodes
  }
}
