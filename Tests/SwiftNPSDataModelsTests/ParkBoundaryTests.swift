import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park boundary models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkBoundaryTests {
  @Test("A recorded MultiPolygon boundary decodes its polygons and naming details")
  func aRecordedMultiPolygonBoundaryDecodesItsPolygonsAndNamingDetails() throws {
    let boundary = try decode(.parkBoundaryDryTortugas)
    #expect(boundary.type == "FeatureCollection")
    let feature = try #require(boundary.features?.first)
    #expect(boundary.features?.count == 1)
    #expect(feature.type == "Feature")
    #expect(feature.id == "4b4ca1b1-41ac-4f9f-2c63-08d4c7ad36e2")
    let geometry = try #require(feature.geometry)
    #expect(geometry.type == "MultiPolygon")
    #expect(geometry.polygon == nil)
    let polygons = try #require(geometry.multiPolygon)
    #expect(polygons.map { $0.map(\.count) } == [[7], [10]])
    #expect(polygons[0][0].first == [-81.7563204, 24.5665621])
    #expect(polygons[0][0].last == [-81.7563204, 24.5665621])
    #expect(polygons[1][0].first == [-82.7652229, 24.7016368])
    let details = try #require(feature.properties)
    #expect(details.alternateName == "Dry Tortugas")
    #expect(details.fullName == "Dry Tortugas National Park")
    #expect(details.name == "Dry Tortugas")
    let alias = try #require(details.aliases?.first)
    #expect(details.aliases?.count == 1)
    #expect(alias.current == true)
    #expect(alias.id == "4a474510-0101-4d07-b258-5e7c021f35bb")
    #expect(alias.name == "DRTO")
    #expect(alias.parkId == feature.id)
  }

  @Test("A recorded Polygon boundary decodes one closed ring and its designation")
  func aRecordedPolygonBoundaryDecodesOneClosedRingAndItsDesignation() throws {
    let boundary = try decode(.parkBoundaryYellowstone)
    let feature = try #require(boundary.features?.first)
    #expect(boundary.features?.count == 1)
    #expect(feature.id == "aff55cd7-4a32-46dd-2e35-08d4c7ad36e2")
    let geometry = try #require(feature.geometry)
    #expect(geometry.type == "Polygon")
    #expect(geometry.multiPolygon == nil)
    let rings = try #require(geometry.polygon)
    #expect(rings.count == 1)
    #expect(rings[0].count == 1494)
    #expect(rings[0].allSatisfy { $0.count == 2 })
    #expect(rings[0][0] == [-111.1023343, 45.1080699])
    #expect(rings[0][1] == [-111.1037557, 45.1089753])
    #expect(rings[0].last == rings[0].first)
    let details = try #require(feature.properties)
    #expect(details.alternateName == "Yellowstone")
    #expect(details.designationId == "128d87ea-e967-4c02-e814-08d4c7ad3656")
    #expect(details.fullName == "Yellowstone National Park")
    #expect(details.name == "Yellowstone")
    #expect(details.aliases?.map(\.name) == ["YELL"])
    #expect(details.aliases?.map(\.parkId) == [feature.id])
    let designation = try #require(details.designation)
    #expect(designation.abbreviation == "NP")
    #expect(designation.description == "National Park")
    #expect(designation.id == details.designationId)
    #expect(designation.name == "National Park")
    #expect(designation.parkDesignationCategoryId == "77d93696-1fee-4033-841d-5140d70e867c")
  }

  @Test(
    "Recorded boundaries survive an encode and decode round trip",
    arguments: [Fixture.parkBoundaryDryTortugas, .parkBoundaryYellowstone])
  func recordedBoundariesSurviveAnEncodeAndDecodeRoundTrip(_ fixture: Fixture) throws {
    let boundary = try decode(fixture)
    let encoded = try JSONEncoder().encode(boundary)
    #expect(try JSONDecoder().decode(ParkBoundary.self, from: encoded) == boundary)
  }

  @Test("Park boundary endpoints put the park code in the path as given")
  func parkBoundaryEndpointsPutTheParkCodeInThePathAsGiven() throws {
    #expect(
      Endpoint.parkBoundary(parkCode: try ParkCode("drto")).path
        == "/mapdata/parkboundaries/drto")
    #expect(
      Endpoint.parkBoundary(parkCode: try ParkCode("YELL")).path
        == "/mapdata/parkboundaries/YELL")
  }

  @Test("Park boundary requests resolve to their endpoint")
  func parkBoundaryRequestsResolveToTheirEndpoint() throws {
    let code = try ParkCode("drto")
    let request = NPSDataRequest.parkBoundary(parkCode: code)
    #expect(request == NPSDataRequest(endpoint: .parkBoundary(parkCode: code)))
    guard case .endpoint(let endpoint) = request.resolution else {
      Issue.record("A park boundary request resolves to one endpoint.")
      return
    }
    #expect(endpoint.path == "/mapdata/parkboundaries/drto")
    #expect(NPSDataRequest.parkBoundary(parkCode: try ParkCode("yell")) != request)
  }

  private func decode(_ fixture: Fixture) throws -> ParkBoundary {
    try JSONDecoder().decode(ParkBoundary.self, from: fixture.data())
  }
}
