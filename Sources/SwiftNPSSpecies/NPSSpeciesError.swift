// The public error carries TransportError without adding a wrapper namespace.
public import HTTPCore

/// A Species request failed without retrying or following redirects.
public enum NPSSpeciesError: Error, Sendable {
  /// Category XML is malformed, incomplete, or declares unsupported entities.
  case invalidCategoryResponse

  /// HTTP status, raw response, decoding, connection, or cancellation failure.
  case transport(TransportError)
}
