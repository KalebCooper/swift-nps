import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSDataTestSupport
import SwiftNPSUnits
import SwiftNPSUnitsModels
import Testing

@Suite("Units client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSUnitsClientTests {
  @Test("All units agrees across all three entry points")
  func allUnitsAgreesAcrossAllThreeEntryPoints() async throws {
    let body = try IRMAFixture.unitAcadia.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = NPSUnitsRequest.units()
    let a = try await client.units()
    let b = try await client.value(for: request)
    let c = try await client.send(.units())
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.path == "/Unit/v2/api/?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Cancellation before sending produces a typed failure without transport")
  func cancellationBeforeSendingProducesATypedFailureWithoutTransport() async throws {
    let transport = MockTransport()
    let client = NPSUnitsClient(transport: transport)
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSUnitsError) {
          _ = try await client.units()
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
    transport.setHandler(forPath: "/Unit/v2/api/") { _ in
      .success(
        MockTransport.Answer(
          body: {
            entered.continuation.yield(())
            return StreamedBody(body.stream)
          }, headers: [.contentType: "application/json"]))
    }
    let task = Task { () -> Bool in
      do throws(NPSUnitsError) {
        _ = try await NPSUnitsClient(transport: transport).units()
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
    let endpoint = try #require(UnitEndpoint<Consumer>(path: "/custom"))
    let request = NPSUnitsRequest(endpoint: endpoint)
    let transport = MockTransport(results: [.success(.ok(json: Data(#"{"count":7}"#.utf8)))])
    let value = try await NPSUnitsClient(transport: transport).value(for: request)
    #expect(value.count == 7)
    #expect(request.endpoint.path == "/custom")
  }

  @Test("Failures preserve HTTP bytes headers decoding and transport errors")
  func failuresPreserveHTTPBytesHeadersDecodingAndTransportErrors() async throws {
    let body = try IRMAFixture.unitHTTPFailure.data()
    let transport = MockTransport(results: [
      .success(
        Response(body: body, headers: [.contentType: "text/html"], status: .internalServerError)),
      .success(.ok(json: Data("invalid JSON".utf8))),
      .failure(.cancelled),
    ])
    let client = NPSUnitsClient(transport: transport)
    do throws(NPSUnitsError) {
      _ = try await client.units()
      Issue.record("HTTP failure must throw.")
    } catch {
      guard case .transport(.httpStatus(let received, let status, let headers)) = error else {
        Issue.record("Expected HTTP failure."); return
      }
      #expect(received == body)
      #expect(status == 500)
      #expect(headers[.contentType] == "text/html")
    }
    do throws(NPSUnitsError) {
      _ = try await client.units()
      Issue.record("Malformed JSON must throw.")
    } catch {
      guard case .transport(.decode) = error else {
        Issue.record("Expected decoding failure."); return
      }
    }
    do throws(NPSUnitsError) {
      _ = try await client.units()
      Issue.record("Transport cancellation must throw.")
    } catch {
      guard case .transport(.cancelled) = error else {
        Issue.record("Expected cancellation."); return
      }
    }
  }

  @Test("Invalid client inputs fail before transport", arguments: ["", "..", "A/B", "A%2FB"])
  func invalidClientInputsFailBeforeTransport(_ value: String) async {
    for route in 0..<4 {
      let transport = MockTransport()
      let client = NPSUnitsClient(transport: transport)
      do throws(NPSUnitsError) {
        switch route {
        case 0: _ = try await client.units(matching: value)
        case 1: _ = try await client.linkedUnits(unitCode: value, kind: .all)
        case 2: _ = try await client.unitDesignation(code: value)
        default: _ = try await client.unitSubtype(code: value)
        }
        Issue.record("Invalid input must fail.")
      } catch {
        guard case .invalidInput = error else { Issue.record("Expected invalid input."); return }
      }
      #expect(transport.requests.isEmpty)
    }
  }

  @Test("Linked units agree across all three entry points", arguments: UnitLinkKind.allCases)
  func linkedUnitsAgreeAcrossAllThreeEntryPoints(_ kind: UnitLinkKind) async throws {
    let fixture: IRMAFixture =
      switch kind {
      case .all: .unitLinked;
      case .functional: .unitLinkedFunctional;
      case .logical: .unitLinkedLogical
      }
    let suffix =
      switch kind {
      case .all: "";
      case .functional: "/functional";
      case .logical: "/logical"
      }
    let body = try fixture.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = try NPSUnitsRequest.linkedUnits(unitCode: "NETN", kind: kind)
    let a = try await client.linkedUnits(unitCode: "NETN", kind: kind)
    let b = try await client.value(for: request)
    let c = try await client.send(.linkedUnits(unitCode: "NETN", kind: kind))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.path == "/Unit/v2/api/NETN/linked" + suffix + "?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Name and unknown searches retain provider results")
  func nameAndUnknownSearchesRetainProviderResults() async throws {
    for (fixture, term, expected) in [
      (IRMAFixture.unitName, "Acadia", ["ACAD", "MAAC"]),
      (IRMAFixture.unitEmpty, "ZZZZ", []),
    ] {
      let body = try fixture.data()
      let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
      let client = NPSUnitsClient(transport: transport)
      let a = try await client.units(matching: term)
      let b = try await client.value(for: .units(matching: term))
      let c = try await client.send(.units(matching: term))
      #expect(a.map(\.unitCode) == expected)
      #expect(a == b && b == c)
      #expect(
        transport.requests.allSatisfy { $0.request.path == "/Unit/v2/api/" + term + "?format=json" }
      )
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
    do throws(NPSUnitsError) {
      _ = try await NPSUnitsClient(transport: transport).units()
      Issue.record("Redirect must fail.")
    } catch {
      guard case .transport = error else { Issue.record("Expected transport failure."); return }
    }
    #expect(transport.requests.count == 1)
  }

  @Test("Unit collections agrees across all three entry points")
  func unitCollectionsAgreesAcrossAllThreeEntryPoints() async throws {
    let body = try IRMAFixture.unitCollections.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = NPSUnitsRequest.unitCollections()
    let a = try await client.unitCollections()
    let b = try await client.value(for: request)
    let c = try await client.send(.unitCollections())
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.path == "/Unit/v2/api/collections?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Unit designation agrees across all three entry points")
  func unitDesignationAgreesAcrossAllThreeEntryPoints() async throws {
    let body = try IRMAFixture.unitDesignation.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = try NPSUnitsRequest.unitDesignation(code: "NP")
    let a = try await client.unitDesignation(code: "NP")
    let b = try await client.value(for: request)
    let c = try await client.send(.unitDesignation(code: "NP"))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.path == "/Unit/v2/api/designations/NP?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Unit designations agrees across all three entry points")
  func unitDesignationsAgreesAcrossAllThreeEntryPoints() async throws {
    let body = try IRMAFixture.unitDesignations.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = NPSUnitsRequest.unitDesignations()
    let a = try await client.unitDesignations()
    let b = try await client.value(for: request)
    let c = try await client.send(.unitDesignations())
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.path == "/Unit/v2/api/designations?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Unit search agrees across all three entry points")
  func unitSearchAgreesAcrossAllThreeEntryPoints() async throws {
    let body = try IRMAFixture.unitAcadia.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = try NPSUnitsRequest.units(matching: "ACAD")
    let a = try await client.units(matching: "ACAD")
    let b = try await client.value(for: request)
    let c = try await client.send(.units(matching: "ACAD"))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.path == "/Unit/v2/api/ACAD?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }
  @Test("Unit subtype agrees across all three entry points")
  func unitSubtypeAgreesAcrossAllThreeEntryPoints() async throws {
    let body = try IRMAFixture.unitSubtype.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = try NPSUnitsRequest.unitSubtype(code: "OP")
    let a = try await client.unitSubtype(code: "OP")
    let b = try await client.value(for: request)
    let c = try await client.send(.unitSubtype(code: "OP"))
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.path == "/Unit/v2/api/subtypes/OP?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Unit subtypes agrees across all three entry points")
  func unitSubtypesAgreesAcrossAllThreeEntryPoints() async throws {
    let body = try IRMAFixture.unitSubtypes.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: body)), count: 3))
    let client = NPSUnitsClient(transport: transport)
    let request = NPSUnitsRequest.unitSubtypes()
    let a = try await client.unitSubtypes()
    let b = try await client.value(for: request)
    let c = try await client.send(.unitSubtypes())
    #expect(a == b && b == c)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.path == "/Unit/v2/api/subtypes?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(call.request.headerFields[key] == nil)
      #expect(call.request.headerFields[.accept] == "application/json")
    }
  }

}
