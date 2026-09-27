// Public transport errors remain inspectable without an additional HTTPCore import.
@_exported import HTTPCore

/// Failures from the NPS Taxonomy client.
public enum NPSTaxonomyError: Error, Sendable {
  /// An input cannot safely identify a route.
  case invalidInput
  /// The original HTTP, decoding, connection, or cancellation failure.
  case transport(TransportError)
}
