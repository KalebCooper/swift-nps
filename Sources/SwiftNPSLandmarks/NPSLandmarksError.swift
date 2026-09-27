// Public transport errors remain inspectable without an additional HTTPCore import.
@_exported import HTTPCore

/// Failures from the NPS Landmark client.
public enum NPSLandmarksError: Error, Sendable {
  /// An input cannot safely identify a route.
  case invalidInput
  /// The original HTTP, decoding, connection, or cancellation failure.
  case transport(TransportError)
}
