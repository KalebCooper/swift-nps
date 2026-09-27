import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSDataTestSupport
import SwiftNPSSpecies
import SwiftNPSSpeciesModels
import Testing

@Suite("Species category XML", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct SpeciesCategoryXMLTests {
  @Test("Cancellation before send performs no transport")
  func cancellationBeforeSendPerformsNoTransport() async throws {
    let transport = MockTransport()
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSSpeciesError) {
          _ = try await NPSSpeciesClient(transport: transport).categoryOptions()
          Issue.record("Cancelled work must fail.")
        } catch {
          guard case .transport(.cancelled) = error else {
            Issue.record("Expected cancellation."); return
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
    transport.setHandler(forPath: "/NPSpecies/v3/rest/urlOptions/categories") { _ in
      .success(
        MockTransport.Answer(
          body: {
            entered.continuation.yield(())
            return StreamedBody(body.stream)
          }, headers: [.contentType: "application/xml"]))
    }
    let task = Task { () -> Bool in
      do throws(NPSSpeciesError) {
        _ = try await NPSSpeciesClient(transport: transport).categoryOptions()
        return false
      } catch {
        if case .transport(.cancelled) = error { return true }
        return false
      }
    }
    var iterator = entered.stream.makeAsyncIterator()
    _ = await iterator.next()
    task.cancel()
    body.continuation.yield(Data("<ArrayOfQueryOption/>".utf8))
    body.continuation.finish()
    entered.continuation.finish()
    #expect(await task.value)
    #expect(transport.requests.count == 1)
  }

  @Test("Category options decode XML despite a JSON format request")
  func categoriesDecodeTheActualRepresentation() async throws {
    let xml = try IRMAFixture.speciesCategoryOptions.data()
    let transport = MockTransport(
      results: Array(
        repeating: .success(
          Response(body: xml, headers: [.contentType: "application/xml"], status: .ok)), count: 3))
    let client = NPSSpeciesClient(transport: transport)
    let a = try await client.categoryOptions()
    let request = SpeciesCategoriesRequest()
    let b = try await client.value(for: request)
    let c = try await client.send(SpeciesCategoriesEndpoint())
    #expect(a == b && b == c && a.count == 17)
    #expect(a.first?.value == "1 or Mammals or Mammal")
    #expect(a.first?.description == "Use any one of the values to get results for this category")
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    #expect(
      transport.requests.allSatisfy {
        $0.request.path == "/NPSpecies/v3/rest/urlOptions/categories?format=json"
          && $0.request.headerFields[key] == nil
      })
  }

  @Test("Empty arrays remain empty")
  func emptyArraysRemainEmpty() async throws {
    let transport = MockTransport(results: [.success(.ok(json: Data("<ArrayOfQueryOption/>".utf8)))]
    )
    #expect(try await NPSSpeciesClient(transport: transport).categoryOptions().isEmpty)
  }

  @Test("HTTP failure is preserved before XML decoding")
  func httpFailureIsPreservedBeforeXMLDecoding() async throws {
    let body = Data("not XML".utf8)
    let transport = MockTransport(results: [
      .success(
        Response(body: body, headers: [.contentType: "text/plain"], status: .internalServerError))
    ])
    do throws(NPSSpeciesError) {
      _ = try await NPSSpeciesClient(transport: transport).categoryOptions()
      Issue.record("Expected HTTP failure.")
    } catch {
      guard case .transport(.httpStatus(let received, let status, let headers)) = error else {
        Issue.record("Expected HTTP status."); return
      }
      #expect(received == body && status == 500 && headers[.contentType] == "text/plain")
    }
  }

  @Test(
    "Invalid documents fail without secondary requests",
    arguments: [
      "<WrongRoot/>",
      "<ArrayOfQueryOption><QueryOption><Value>x</Value></QueryOption></ArrayOfQueryOption>",
      "<ArrayOfQueryOption><QueryOption>",
      "<!DOCTYPE ArrayOfQueryOption [<!ENTITY x SYSTEM 'https://example.com/private'>]><ArrayOfQueryOption><QueryOption><Value>&x;</Value><Description>d</Description></QueryOption></ArrayOfQueryOption>",
      "<ArrayOfQueryOption><QueryOption><Value>a</Value><Value>b</Value><Description>d</Description></QueryOption></ArrayOfQueryOption>",
    ])
  func invalidDocumentsFailWithoutSecondaryRequests(_ xml: String) async throws {
    let transport = MockTransport(results: [.success(.ok(json: Data(xml.utf8)))])
    do throws(NPSSpeciesError) {
      _ = try await NPSSpeciesClient(transport: transport).categoryOptions()
      Issue.record("Invalid XML must fail.")
    } catch {
      guard case .invalidCategoryResponse = error else {
        Issue.record("Expected category error."); return
      }
    }
    #expect(transport.requests.count == 1)
  }

  @Test("Namespaces and chunked text preserve values exactly")
  func namespacesAndChunkedTextPreserveValuesExactly() async throws {
    let xml =
      "<n:ArrayOfQueryOption xmlns:n='urn:test'><n:QueryOption><n:Value> A&amp;B<![CDATA[ + C]]> </n:Value><n:Description>First&#10;Second</n:Description></n:QueryOption></n:ArrayOfQueryOption>"
    let transport = MockTransport(results: [.success(.ok(json: Data(xml.utf8)))])
    let values = try await NPSSpeciesClient(transport: transport).categoryOptions()
    #expect(values == [SpeciesCategoryOption(description: "First\nSecond", value: " A&B + C ")])
  }
}
