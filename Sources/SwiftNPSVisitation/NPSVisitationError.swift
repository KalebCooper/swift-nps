// Public transport errors remain inspectable without an additional HTTPCore import.
@_exported import HTTPCore

/// Failures from the NPS statistics client.
public enum NPSVisitationError: Error, Sendable {
  /// A national statistics request supplied a nonpositive year.
  case invalidYear
  /// The original HTTP, decoding, connection, or cancellation failure.
  case transport(TransportError)
}
