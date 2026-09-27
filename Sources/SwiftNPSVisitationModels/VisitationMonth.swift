#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A validated positive year and month used to request visitation statistics.
public struct VisitationMonth: Hashable, Sendable {
  /// Invalid calendar components for a statistics request.
  public enum ValidationError: Error, Hashable, Sendable {
    /// The month is outside 1 through 12.
    case invalidMonth
    /// The year is not positive.
    case invalidYear
  }

  /// The month in 1 through 12.
  public let month: Int
  /// The positive year.
  public let year: Int

  /// Creates a month without choosing a day or time zone.
  ///
  /// Calendar components intentionally follow larger-to-smaller order.
  /// - Parameters:
  ///   - year: A positive year.
  ///   - month: A month in 1 through 12.
  /// - Throws: A component-specific validation error.
  public init(year: Int, month: Int) throws(ValidationError) {
    guard year > 0 else { throw .invalidYear }
    guard (1...12).contains(month) else { throw .invalidMonth }
    self.month = month
    self.year = year
  }
}
