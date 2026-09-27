#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import SwiftNPSUnitsModels

extension NPSUnitsClient {
  /// Fetches unitCounty, preserving the provider response without geometry conversion or traversal.
  /// - Throws: Invalid input or the original transport failure, including cancellation.
  public func unitCounty(state: String, county: String) async throws(NPSUnitsError) -> UnitCounty {
    let request: NPSUnitsRequest<UnitCounty>
    do { request = try .unitCounty(state: state, county: county) } catch { throw .invalidInput }
    return try await value(for: request)
  }

  /// Fetches unitGeographies, preserving the provider response without geometry conversion or traversal.
  /// - Throws: Invalid input or the original transport failure, including cancellation.
  public func unitGeographies(query: UnitGeographyQuery) async throws(NPSUnitsError)
    -> [UnitGeography]
  {
    try await value(for: .unitGeographies(query: query))
  }

  /// Fetches unitPoints, preserving the provider response without geometry conversion or traversal.
  /// - Throws: Invalid input or the original transport failure, including cancellation.
  public func unitPoints() async throws(NPSUnitsError) -> [UnitPoint] {
    try await value(for: .unitPoints())
  }

  /// Fetches unitSelector, preserving the provider response without geometry conversion or traversal.
  /// - Throws: Invalid input or the original transport failure, including cancellation.
  public func unitSelector() async throws(NPSUnitsError) -> [UnitNode] {
    try await value(for: .unitSelector())
  }

  /// Fetches unitState, preserving the provider response without geometry conversion or traversal.
  /// - Throws: Invalid input or the original transport failure, including cancellation.
  public func unitState(code: String) async throws(NPSUnitsError) -> UnitState {
    let request: NPSUnitsRequest<UnitState>
    do { request = try .unitState(code: code) } catch { throw .invalidInput }
    return try await value(for: request)
  }

  /// Fetches unitStates, preserving the provider response without geometry conversion or traversal.
  /// - Throws: Invalid input or the original transport failure, including cancellation.
  public func unitStates() async throws(NPSUnitsError) -> [UnitState] {
    try await value(for: .unitStates())
  }
}
