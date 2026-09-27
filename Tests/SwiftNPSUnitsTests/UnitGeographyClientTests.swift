import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSDataTestSupport
import SwiftNPSUnits
import SwiftNPSUnitsModels
import Testing

@Suite("Unit geography client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct UnitGeographyClientTests {

  @Test("County identifiers retain numeric and FIPS text")
  func countyIdentifiersRetainNumericAndFIPSText() throws {
    #expect(
      try UnitEndpoint.unitCounty(state: "ME", county: "4336").path == "/states/ME/4336?format=json"
    )
    #expect(
      try NPSUnitsRequest.unitCounty(state: "ME", county: "23009").endpoint.path
        == "/states/ME/23009?format=json")
  }

  @Test(
    "Invalid state and county components fail without transport", arguments: ["", "..", "ME/WY"])
  func invalidStateAndCountyComponentsFailWithoutTransport(_ value: String) async {
    for route in 0..<3 {
      let transport = MockTransport()
      let client = NPSUnitsClient(transport: transport)
      do throws(NPSUnitsError) {
        switch route {
        case 0: _ = try await client.unitState(code: value)
        case 1: _ = try await client.unitCounty(state: value, county: "Hancock County")
        default: _ = try await client.unitCounty(state: "ME", county: value)
        }
        Issue.record("Invalid route input must fail.")
      } catch {
        guard case .invalidInput = error else { Issue.record("Expected invalid input."); return }
      }
      #expect(transport.requests.isEmpty)
    }
  }

  @Test("unitCounty preserves its typed response across entry points")
  func unitCountyPreservesItsTypedResponseAcrossEntryPoints() async throws {
    let body = try IRMAFixture.unitCountyHancock.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = try NPSUnitsRequest.unitCounty(state: "ME", county: "Hancock County")
    let a = try await client.unitCounty(state: "ME", county: "Hancock County")
    let b = try await client.value(for: request)
    let c = try await client.send(.unitCounty(state: "ME", county: "Hancock County"))
    #expect(a == b && b == c)
    #expect(
      transport.requests.allSatisfy {
        $0.request.path == "/Unit/v2/api/states/ME/Hancock%20County?format=json"
      })
  }

  @Test("unitGeographies preserves its typed response across entry points")
  func unitGeographiesPreservesItsTypedResponseAcrossEntryPoints() async throws {
    let body = try IRMAFixture.unitAcadiaGeography.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = try NPSUnitsRequest.unitGeographies(query: UnitGeographyQuery(searchTerm: "ACAD"))
    let a = try await client.unitGeographies(query: UnitGeographyQuery(searchTerm: "ACAD"))
    let b = try await client.value(for: request)
    let c = try await client.send(.unitGeographies(query: UnitGeographyQuery(searchTerm: "ACAD")))
    #expect(a == b && b == c)
    #expect(
      transport.requests.allSatisfy { $0.request.path == "/Unit/v2/api/ACAD/geography?format=json" }
    )
  }

  @Test("unitPoints preserves its typed response across entry points")
  func unitPointsPreservesItsTypedResponseAcrossEntryPoints() async throws {
    let body = try IRMAFixture.unitPoints.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = NPSUnitsRequest.unitPoints()
    let a = try await client.unitPoints()
    let b = try await client.value(for: request)
    let c = try await client.send(.unitPoints())
    #expect(a == b && b == c)
    #expect(
      transport.requests.allSatisfy { $0.request.path == "/Unit/v2/api/unitpoints?format=json" })
  }

  @Test("unitSelector preserves its typed response across entry points")
  func unitSelectorPreservesItsTypedResponseAcrossEntryPoints() async throws {
    let body = try IRMAFixture.unitSelector.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = NPSUnitsRequest.unitSelector()
    let a = try await client.unitSelector()
    let b = try await client.value(for: request)
    let c = try await client.send(.unitSelector())
    #expect(a == b && b == c)
    #expect(
      transport.requests.allSatisfy { $0.request.path == "/Unit/v2/api/unitselector?format=json" })
  }

  @Test("unitState preserves its typed response across entry points")
  func unitStatePreservesItsTypedResponseAcrossEntryPoints() async throws {
    let body = try IRMAFixture.unitStateMaine.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = try NPSUnitsRequest.unitState(code: "ME")
    let a = try await client.unitState(code: "ME")
    let b = try await client.value(for: request)
    let c = try await client.send(.unitState(code: "ME"))
    #expect(a == b && b == c)
    #expect(
      transport.requests.allSatisfy { $0.request.path == "/Unit/v2/api/states/ME?format=json" })
  }

  @Test("unitStates preserves its typed response across entry points")
  func unitStatesPreservesItsTypedResponseAcrossEntryPoints() async throws {
    let body = try IRMAFixture.unitStates.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = NPSUnitsRequest.unitStates()
    let a = try await client.unitStates()
    let b = try await client.value(for: request)
    let c = try await client.send(.unitStates())
    #expect(a == b && b == c)
    #expect(transport.requests.allSatisfy { $0.request.path == "/Unit/v2/api/states?format=json" })
  }

  @Test("Unknown geography retains an empty response")
  func unknownGeographyRetainsAnEmptyResponse() async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try IRMAFixture.unitGeographyEmpty.data()))
    ])
    let rows = try await NPSUnitsClient(transport: transport).unitGeographies(
      query: UnitGeographyQuery(searchTerm: "ZZZZ"))
    #expect(rows.isEmpty)
    #expect(transport.requests.first?.request.path == "/Unit/v2/api/ZZZZ/geography?format=json")
  }
}
