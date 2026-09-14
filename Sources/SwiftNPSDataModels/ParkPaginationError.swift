/// Why a parks response cannot safely determine pagination progress.
///
/// Single-page decoding preserves metadata as strings. ``ParkQuery/next(after:)`` validates it
/// only when interpreting pagination, without substituting a guessed count or offset.
public enum ParkPaginationError: Error, Hashable, Sendable {
  /// The returned count contradicts the limit or total, or an empty page precedes the total.
  case inconsistentPage
  /// A named metadata value is not a usable nonnegative integer, or the limit is zero.
  case invalidMetadata(field: String, value: String)
  /// Advancing the offset would overflow an integer.
  case offsetOverflow
  /// The response offset differs from the requested offset.
  case unexpectedStart(actual: Int, expected: Int)
}
