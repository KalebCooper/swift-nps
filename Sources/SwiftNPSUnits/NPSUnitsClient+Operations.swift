#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import SwiftNPSUnitsModels

extension NPSUnitsClient {
  /// Fetches linkedUnits as one provider response, without pagination or key credentials.
  /// - Throws: Invalid input or the original transport, HTTP, decoding, or cancellation failure.
  public func linkedUnits(unitCode: String, kind: UnitLinkKind) async throws(NPSUnitsError)
    -> [NPSUnit]
  {
    let request: NPSUnitsRequest<[NPSUnit]>
    do { request = try .linkedUnits(unitCode: unitCode, kind: kind) } catch { throw .invalidInput }
    return try await value(for: request)
  }

  /// Fetches unitCollections as one provider response, without pagination or key credentials.
  /// - Throws: Invalid input or the original transport, HTTP, decoding, or cancellation failure.
  public func unitCollections() async throws(NPSUnitsError) -> [UnitCollection] {
    try await value(for: .unitCollections())
  }

  /// Fetches unitDesignation as one provider response, without pagination or key credentials.
  /// - Throws: Invalid input or the original transport, HTTP, decoding, or cancellation failure.
  public func unitDesignation(code: String) async throws(NPSUnitsError) -> UnitDesignation {
    let request: NPSUnitsRequest<UnitDesignation>
    do { request = try .unitDesignation(code: code) } catch { throw .invalidInput }
    return try await value(for: request)
  }

  /// Fetches unitDesignations as one provider response, without pagination or key credentials.
  /// - Throws: Invalid input or the original transport, HTTP, decoding, or cancellation failure.
  public func unitDesignations() async throws(NPSUnitsError) -> [UnitDesignation] {
    try await value(for: .unitDesignations())
  }

  /// Fetches unitSubtype as one provider response, without pagination or key credentials.
  /// - Throws: Invalid input or the original transport, HTTP, decoding, or cancellation failure.
  public func unitSubtype(code: String) async throws(NPSUnitsError) -> UnitSubtype {
    let request: NPSUnitsRequest<UnitSubtype>
    do { request = try .unitSubtype(code: code) } catch { throw .invalidInput }
    return try await value(for: request)
  }

  /// Fetches unitSubtypes as one provider response, without pagination or key credentials.
  /// - Throws: Invalid input or the original transport, HTTP, decoding, or cancellation failure.
  public func unitSubtypes() async throws(NPSUnitsError) -> [UnitSubtype] {
    try await value(for: .unitSubtypes())
  }

  /// Fetches units as one provider response, without pagination or key credentials.
  /// - Throws: Invalid input or the original transport, HTTP, decoding, or cancellation failure.
  public func units() async throws(NPSUnitsError) -> [NPSUnit] {
    try await value(for: .units())
  }

  /// Fetches units as one provider response, without pagination or key credentials.
  /// - Throws: Invalid input or the original transport, HTTP, decoding, or cancellation failure.
  public func units(matching searchTerm: String) async throws(NPSUnitsError) -> [NPSUnit] {
    let request: NPSUnitsRequest<[NPSUnit]>
    do { request = try .units(matching: searchTerm) } catch { throw .invalidInput }
    return try await value(for: request)
  }
}
