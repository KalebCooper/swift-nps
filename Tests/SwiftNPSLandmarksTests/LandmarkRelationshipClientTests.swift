import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSDataTestSupport
import SwiftNPSLandmarks
import SwiftNPSLandmarksModels
import Testing

@Suite("Landmark relationship client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct LandmarkRelationshipClientTests {
  @Test("Every relationship route honors cancellation before transport", arguments: 0..<5)
  func cancellationBeforeTransport(_ route: Int) async throws {
    let transport = MockTransport()
    let client = NPSLandmarksClient(transport: transport)
    await withTaskGroup(of: Bool.self) { group in
      group.cancelAll()
      group.addTask {
        do {
          try await Self.fetch(route, client: client)
          return false
        } catch NPSLandmarksError.transport(.cancelled) { return true } catch { return false }
      }
      for await result in group { #expect(result) }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("Every relationship route preserves HTTP failures", arguments: 0..<5)
  func failures(_ route: Int) async throws {
    let body = try IRMAFixture.landmarkHTTPFailure.data()
    let transport = MockTransport(results: [
      .success(
        Response(
          body: body, headers: [.contentType: "application/json"], status: .internalServerError))
    ])
    do {
      try await Self.fetch(route, client: NPSLandmarksClient(transport: transport))
      Issue.record("HTTP failure must throw.")
    } catch NPSLandmarksError.transport(.httpStatus(let data, let status, let headers)) {
      #expect(data == body && status == 500 && headers[.contentType] == "application/json")
    }
  }

  private static func fetch(_ route: Int, client: NPSLandmarksClient) async throws {
    switch route {
    case 0: _ = try await client.landmarkOwners(query: LandmarkOwnerQuery())
    case 1: _ = try await client.landmarkSiteCounties(query: LandmarkQuery())
    case 2: _ = try await client.landmarkStateCounties(query: LandmarkStateCountyQuery())
    case 3: _ = try await client.landmarksWithCounty(query: LandmarkQuery())
    default: _ = try await client.statesAndLandmarks()
    }
  }

  @Test("OwnersEmpty agrees across all three entry points")
  func ownersEmptyEquivalence() async throws {
    let data = try IRMAFixture.landmarkOwnerEmpty.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarkOwners(query: try LandmarkOwnerQuery(code: "ZZZZ"))
    let a = try await client.landmarkOwners(query: try LandmarkOwnerQuery(code: "ZZZZ"))
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarkOwners(query: try LandmarkOwnerQuery(code: "ZZZZ")))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/LandmarkOwnerInformation?Code=ZZZZ")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Owners agrees across all three entry points")
  func ownersEquivalence() async throws {
    let data = try IRMAFixture.landmarkOwners.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarkOwners(query: try LandmarkOwnerQuery(code: "APBO-ME"))
    let a = try await client.landmarkOwners(query: try LandmarkOwnerQuery(code: "APBO-ME"))
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarkOwners(query: try LandmarkOwnerQuery(code: "APBO-ME")))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/LandmarkOwnerInformation?Code=APBO-ME")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("SiteCountiesEmpty agrees across all three entry points")
  func siteCountiesEmptyEquivalence() async throws {
    let data = try IRMAFixture.landmarkSiteCountiesEmpty.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarkSiteCounties(query: try LandmarkQuery(code: "ZZZZ"))
    let a = try await client.landmarkSiteCounties(query: try LandmarkQuery(code: "ZZZZ"))
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarkSiteCounties(query: try LandmarkQuery(code: "ZZZZ")))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/SiteCounties?Code=ZZZZ")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("SiteCounties agrees across all three entry points")
  func siteCountiesEquivalence() async throws {
    let data = try IRMAFixture.landmarkAppletonCounties.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarkSiteCounties(
      query: try LandmarkQuery(code: "APBO-ME"))
    let a = try await client.landmarkSiteCounties(query: try LandmarkQuery(code: "APBO-ME"))
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarkSiteCounties(query: try LandmarkQuery(code: "APBO-ME")))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/SiteCounties?Code=APBO-ME")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("StateCountiesEmpty agrees across all three entry points")
  func stateCountiesEmptyEquivalence() async throws {
    let data = try IRMAFixture.landmarkStateCountiesEmpty.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarkStateCounties(
      query: try LandmarkStateCountyQuery(stateCode: "ZZ"))
    let a = try await client.landmarkStateCounties(
      query: try LandmarkStateCountyQuery(stateCode: "ZZ"))
    let b = try await client.value(for: request)
    let c = try await client.send(
      .landmarkStateCounties(query: try LandmarkStateCountyQuery(stateCode: "ZZ")))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/StateCounty?StateCode=ZZ")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("StateCounties agrees across all three entry points")
  func stateCountiesEquivalence() async throws {
    let data = try IRMAFixture.landmarkStateCounties.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarkStateCounties(
      query: try LandmarkStateCountyQuery(stateCode: "ME"))
    let a = try await client.landmarkStateCounties(
      query: try LandmarkStateCountyQuery(stateCode: "ME"))
    let b = try await client.value(for: request)
    let c = try await client.send(
      .landmarkStateCounties(query: try LandmarkStateCountyQuery(stateCode: "ME")))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/StateCounty?StateCode=ME")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("StatesAndLandmarks agrees across all three entry points")
  func statesAndLandmarksEquivalence() async throws {
    let data = try IRMAFixture.landmarkStateIndex.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.statesAndLandmarks()
    let a = try await client.statesAndLandmarks()
    let b = try await client.value(for: request)
    let c = try await client.send(.statesAndLandmarks())
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/StatesAndLandmarks")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("WithCountyEmpty agrees across all three entry points")
  func withCountyEmptyEquivalence() async throws {
    let data = try IRMAFixture.landmarkWithCountyEmpty.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarksWithCounty(query: try LandmarkQuery(code: "ZZZZ"))
    let a = try await client.landmarksWithCounty(query: try LandmarkQuery(code: "ZZZZ"))
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarksWithCounty(query: try LandmarkQuery(code: "ZZZZ")))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/LandmarkInformationWithCounty?Code=ZZZZ")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("WithCounty agrees across all three entry points")
  func withCountyEquivalence() async throws {
    let data = try IRMAFixture.landmarkWithCounty.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarksWithCounty(query: try LandmarkQuery(code: "APBO-ME"))
    let a = try await client.landmarksWithCounty(query: try LandmarkQuery(code: "APBO-ME"))
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarksWithCounty(query: try LandmarkQuery(code: "APBO-ME")))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/LandmarkInformationWithCounty?Code=APBO-ME")
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

}
