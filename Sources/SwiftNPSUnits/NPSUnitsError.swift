// Public transport errors remain inspectable without an additional HTTPCore import.
@_exported import HTTPCore

/// Failures from the NPS Unit client.
public enum NPSUnitsError: Error, Sendable {
  /// An input cannot safely identify a route.
  case invalidInput
  /// The original HTTP, decoding, connection, or cancellation failure.
  case transport(TransportError)
}
