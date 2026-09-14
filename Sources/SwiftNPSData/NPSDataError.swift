#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
// The public client and error name Transport and TransportError, so consumers need their members
// available without separately declaring an HTTPCore dependency.
@_exported import HTTPCore
import SwiftNPSDataModels

/// The typed failure of an NPS client operation or credential configuration.
public enum NPSDataError: Error {
  /// The API key is empty or contains characters unsuitable for an HTTP header.
  ///
  /// The rejected credential is deliberately not attached to the error.
  case invalidAPIKey

  /// The service returned a recognized error envelope.
  ///
  /// The HTTP failure retains the original body, status, and headers, including rate-limit
  /// information. Neither the message nor those fields should be logged without review.
  case service(ServiceErrorResponse, response: TransportError)

  /// A connection, cancellation, decoding, or unrecognized HTTP status failure.
  ///
  /// Redirects are returned here as HTTP failures and are never followed with the API key.
  case transport(TransportError)

  init(_ failure: TransportError) {
    if case .httpStatus(let body, _, _) = failure,
      let response = try? JSONDecoder().decode(ServiceErrorResponse.self, from: body)
    {
      self = .service(response, response: failure)
    } else {
      self = .transport(failure)
    }
  }
}
