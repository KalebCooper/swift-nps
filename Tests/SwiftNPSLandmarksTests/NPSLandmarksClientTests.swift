import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSDataTestSupport
import SwiftNPSLandmarks
import SwiftNPSLandmarksModels
import Testing

@Suite("Landmarks client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSLandmarksClientTests {
  @Test("Cancellation before sending produces a typed failure without transport")
  func cancellationBeforeSendingProducesATypedFailureWithoutTransport() async throws {
    let transport = MockTransport()
    let client = NPSLandmarksClient(transport: transport)
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSLandmarksError) {
          _ = try await client.landmarkStates()
          Issue.record("Cancelled work must fail.")
        } catch {
          guard case .transport(.cancelled) = error else {
            Issue.record("Expected cancellation.")
            return
          }
        }
      }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("Cancellation during a suspended response produces a typed failure")
  func cancellationDuringASuspendedResponseProducesATypedFailure() async throws {
    let body = AsyncStream<Data>.makeStream()
    let entered = AsyncStream<Void>.makeStream()
    let transport = MockTransport()
    transport.setHandler(forPath: "/NNLApi/v1/api/AllStates") { _ in
      .success(
        MockTransport.Answer(
          body: {
            entered.continuation.yield(())
            return StreamedBody(body.stream)
          }, headers: [.contentType: "application/json"]))
    }
    let task = Task { () -> Bool in
      do throws(NPSLandmarksError) {
        _ = try await NPSLandmarksClient(transport: transport).landmarkStates()
        return false
      } catch {
        if case .transport(.cancelled) = error { return true }
        return false
      }
    }
    var iterator = entered.stream.makeAsyncIterator()
    _ = await iterator.next()
    task.cancel()
    body.continuation.yield(Data("[]".utf8))
    body.continuation.finish()
    entered.continuation.finish()
    #expect(await task.value)
    #expect(transport.requests.count == 1)
  }

  @Test("Consumer responses and stored requests preserve concrete inference")
  func consumerResponsesAndStoredRequestsPreserveConcreteInference() async throws {
    struct Consumer: Decodable, Sendable { let count: Int }
    let endpoint = try #require(LandmarkEndpoint<Consumer>(path: "/custom"))
    let request = NPSLandmarksRequest(endpoint: endpoint)
    let transport = MockTransport(results: [.success(.ok(json: Data(#"{"count":7}"#.utf8)))])
    let value = try await NPSLandmarksClient(transport: transport).value(for: request)
    #expect(value.count == 7)
    #expect(request.endpoint.path == "/custom")
  }

  @Test("CountyAll agrees across all three entry points")
  func countyAllEquivalence() async throws {
    let data = try IRMAFixture.landmarkCountyAll.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarkCounty(query: try LandmarkQuery())
    let a = try await client.landmarkCounty(query: try LandmarkQuery())
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarkCounty(query: try LandmarkQuery()))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/County")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("County agrees across all three entry points")
  func countyEquivalence() async throws {
    let data = try IRMAFixture.landmarkCountyMaine.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarkCounty(query: try LandmarkQuery(stateCode: "ME"))
    let a = try await client.landmarkCounty(query: try LandmarkQuery(stateCode: "ME"))
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarkCounty(query: try LandmarkQuery(stateCode: "ME")))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/County?StateCode=ME")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("CountyLandmarks agrees across all three entry points")
  func countyLandmarksEquivalence() async throws {
    let data = try IRMAFixture.landmarkPerCounty.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = try NPSLandmarksRequest.landmarks(countyID: 4347)
    let a = try await client.landmarks(countyID: 4347)
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarks(countyID: 4347))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/LandmarkInformationPerCounty?CountyID=4347")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("EmptyCountyLandmarks agrees across all three entry points")
  func emptyCountyLandmarksEquivalence() async throws {
    let data = try IRMAFixture.landmarkPerCountyEmpty.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = try NPSLandmarksRequest.landmarks(countyID: 99999999)
    let a = try await client.landmarks(countyID: 99999999)
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarks(countyID: 99999999))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/LandmarkInformationPerCounty?CountyID=99999999")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("EmptyLandmarks agrees across all three entry points")
  func emptyLandmarksEquivalence() async throws {
    let data = try IRMAFixture.landmarkEmpty.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarks(query: try LandmarkQuery(code: "ZZZZ"))
    let a = try await client.landmarks(query: try LandmarkQuery(code: "ZZZZ"))
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarks(query: try LandmarkQuery(code: "ZZZZ")))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/LandmarkInformation?Code=ZZZZ")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Failures preserve HTTP bytes headers decoding and transport errors")
  func failuresPreserveHTTPBytesHeadersDecodingAndTransportErrors() async throws {
    let body = try IRMAFixture.landmarkHTTPFailure.data()
    let transport = MockTransport(results: [
      .success(
        Response(body: body, headers: [.contentType: "text/html"], status: .internalServerError)),
      .success(.ok(json: Data("invalid JSON".utf8))),
      .failure(.cancelled),
    ])
    let client = NPSLandmarksClient(transport: transport)
    do throws(NPSLandmarksError) {
      _ = try await client.landmarkStates()
      Issue.record("HTTP failure must throw.")
    } catch {
      guard case .transport(.httpStatus(let received, let status, let headers)) = error else {
        Issue.record("Expected HTTP failure."); return
      }
      #expect(received == body)
      #expect(status == 500)
      #expect(headers[.contentType] == "text/html")
    }
    do throws(NPSLandmarksError) {
      _ = try await client.landmarkStates()
      Issue.record("Malformed JSON must throw.")
    } catch {
      guard case .transport(.decode) = error else {
        Issue.record("Expected decoding failure."); return
      }
    }
    do throws(NPSLandmarksError) {
      _ = try await client.landmarkStates()
      Issue.record("Transport cancellation must throw.")
    } catch {
      guard case .transport(.cancelled) = error else {
        Issue.record("Expected cancellation."); return
      }
    }
  }

  @Test("Invalid direct inputs fail without transport")
  func invalidInputs() async {
    let transport = MockTransport()
    let client = NPSLandmarksClient(transport: transport)
    for index in 0..<4 {
      do throws(NPSLandmarksError) {
        switch index {
        case 0: _ = try await client.landmarkState(stateCode: "")
        case 1: _ = try await client.landmarks(stateCode: "\n")
        case 2: _ = try await client.landmarks(countyID: -1)
        default: _ = try await client.landmarks(countyID: .max)
        }
        Issue.record("Invalid input must throw.")
      } catch {
        guard case .invalidInput = error else { Issue.record("Expected invalidInput."); return }
      }
    }
    #expect(transport.requests.isEmpty)
  }

  @Test("Landmarks agrees across all three entry points")
  func landmarksEquivalence() async throws {
    let data = try IRMAFixture.landmarkAppleton.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarks(query: try LandmarkQuery(code: "APBO-ME"))
    let a = try await client.landmarks(query: try LandmarkQuery(code: "APBO-ME"))
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarks(query: try LandmarkQuery(code: "APBO-ME")))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/LandmarkInformation?Code=APBO-ME")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test(
    "Redirects never escape the service",
    arguments: [
      "https://example.com/collect", "https://irmaservices.nps.gov/v3/rest/stats/total/2025",
    ])
  func redirectsNeverEscapeTheService(_ location: String) async throws {
    let transport = MockTransport(results: [
      .success(Response(body: Data(), headers: [.location: location], status: .found))
    ])
    do throws(NPSLandmarksError) {
      _ = try await NPSLandmarksClient(transport: transport).landmarkStates()
      Issue.record("Redirect must fail.")
    } catch {
      guard case .transport = error else { Issue.record("Expected transport failure."); return }
    }
    #expect(transport.requests.count == 1)
  }

  @Test("State agrees across all three entry points")
  func stateEquivalence() async throws {
    let data = try IRMAFixture.landmarkStateMaine.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = try NPSLandmarksRequest.landmarkState(stateCode: "ME")
    let a = try await client.landmarkState(stateCode: "ME")
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarkState(stateCode: "ME"))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/State?StateCode=ME")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("StateLandmarks agrees across all three entry points")
  func stateLandmarksEquivalence() async throws {
    let data = try IRMAFixture.landmarkMaine.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = try NPSLandmarksRequest.landmarks(stateCode: "ME")
    let a = try await client.landmarks(stateCode: "ME")
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarks(stateCode: "ME"))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/LandmarkInformationPerStateCode?StateCode=ME")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("States agrees across all three entry points")
  func statesEquivalence() async throws {
    let data = try IRMAFixture.landmarkStates.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSLandmarksClient(transport: transport)
    let request = NPSLandmarksRequest.landmarkStates()
    let a = try await client.landmarkStates()
    let b = try await client.value(for: request)
    let c = try await client.send(.landmarkStates())
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(transport.requests.count == 3)
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/NNLApi/v1/api/AllStates")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

}
