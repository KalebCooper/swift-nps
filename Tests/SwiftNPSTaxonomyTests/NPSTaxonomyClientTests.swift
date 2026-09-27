import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSDataTestSupport
import SwiftNPSTaxonomy
import SwiftNPSTaxonomyModels
import Testing

@Suite("Taxonomy client routes", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSTaxonomyClientTests {
  @Test("Cancellation before sending produces a typed failure without transport")
  func cancellationBeforeSendingProducesATypedFailureWithoutTransport() async throws {
    let transport = MockTransport()
    let client = NPSTaxonomyClient(transport: transport)
    await withTaskGroup(of: Void.self) { group in
      group.cancelAll()
      group.addTask {
        do throws(NPSTaxonomyError) {
          _ = try await client.taxonomicSources()
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
    transport.setHandler(forPath: "/taxonomy/v2/rest/sources") { _ in
      .success(
        MockTransport.Answer(
          body: {
            entered.continuation.yield(())
            return StreamedBody(body.stream)
          }, headers: [.contentType: "application/json"]))
    }
    let task = Task { () -> Bool in
      do throws(NPSTaxonomyError) {
        _ = try await NPSTaxonomyClient(transport: transport).taxonomicSources()
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

  @Test("Categories agrees across all three entry points")
  func categoriesEquivalence() async throws {
    let data = try IRMAFixture.taxonomyCategories.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomicCategories()
    let a = try await client.taxonomicCategories()
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomicCategories())
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/categories?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Category agrees across all three entry points")
  func categoryEquivalence() async throws {
    let data = try IRMAFixture.taxonomyCategoryBird.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.taxonomicCategory(code: "Bird")
    let a = try await client.taxonomicCategory(code: "Bird")
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomicCategory(code: "Bird"))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/categories/Bird?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("CommonEmpty agrees across all three entry points")
  func commonEmptyEquivalence() async throws {
    let data = try IRMAFixture.taxonomyEmpty.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonProfilesResponse(
      query: try TaxonProfileQuery(search: .commonName("ZZZZZZZZ", category: nil, source: nil)))
    let a = try await client.taxonProfilesResponse(
      query: try TaxonProfileQuery(search: .commonName("ZZZZZZZZ", category: nil, source: nil)))
    let b = try await client.value(for: request)
    let c = try await client.send(
      .taxonProfilesResponse(
        query: try TaxonProfileQuery(search: .commonName("ZZZZZZZZ", category: nil, source: nil))))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(
        call.request.path
          == "/taxonomy/v2/rest/searchByCommonName/ZZZZZZZZ?deriveIfBroken=false&detail=profile&format=json"
      )
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("CommonProfiles agrees across all three entry points")
  func commonProfilesEquivalence() async throws {
    let data = try IRMAFixture.taxonomyCommonProfiles.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonProfilesResponse(
      query: try TaxonProfileQuery(search: .commonName("osprey", category: nil, source: nil)))
    let a = try await client.taxonProfilesResponse(
      query: try TaxonProfileQuery(search: .commonName("osprey", category: nil, source: nil)))
    let b = try await client.value(for: request)
    let c = try await client.send(
      .taxonProfilesResponse(
        query: try TaxonProfileQuery(search: .commonName("osprey", category: nil, source: nil))))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(
        call.request.path
          == "/taxonomy/v2/rest/searchByCommonName/osprey?deriveIfBroken=false&detail=profile&format=json"
      )
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("CommonSummaries agrees across all three entry points")
  func commonSummariesEquivalence() async throws {
    let data = try IRMAFixture.taxonomyCommonSummaries.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonSummariesResponse(
      query: try TaxonSummaryQuery(search: .commonName("osprey", category: nil, source: nil)))
    let a = try await client.taxonSummariesResponse(
      query: try TaxonSummaryQuery(search: .commonName("osprey", category: nil, source: nil)))
    let b = try await client.value(for: request)
    let c = try await client.send(
      .taxonSummariesResponse(
        query: try TaxonSummaryQuery(search: .commonName("osprey", category: nil, source: nil))))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(
        call.request.path == "/taxonomy/v2/rest/searchByCommonName/osprey?detail=basic&format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Consumer responses and stored requests preserve concrete inference")
  func consumerResponsesAndStoredRequestsPreserveConcreteInference() async throws {
    struct Consumer: Decodable, Sendable { let count: Int }
    let endpoint = try #require(TaxonomyEndpoint<Consumer>(path: "/custom"))
    let request = NPSTaxonomyRequest(endpoint: endpoint)
    let transport = MockTransport(results: [.success(.ok(json: Data(#"{"count":7}"#.utf8)))])
    let value = try await NPSTaxonomyClient(transport: transport).value(for: request)
    #expect(value.count == 7)
    #expect(request.endpoint.path == "/custom")
  }

  @Test("Failures preserve HTTP bytes headers decoding and transport errors")
  func failuresPreserveHTTPBytesHeadersDecodingAndTransportErrors() async throws {
    let body = try IRMAFixture.taxonomyHTTPFailure.data()
    let transport = MockTransport(results: [
      .success(
        Response(body: body, headers: [.contentType: "application/json"], status: .notFound)),
      .success(.ok(json: Data("invalid JSON".utf8))),
      .failure(.cancelled),
    ])
    let client = NPSTaxonomyClient(transport: transport)
    do throws(NPSTaxonomyError) {
      _ = try await client.taxonomicSources()
      Issue.record("HTTP failure must throw.")
    } catch {
      guard case .transport(.httpStatus(let received, let status, let headers)) = error else {
        Issue.record("Expected HTTP failure."); return
      }
      #expect(received == body)
      #expect(status == 404)
      #expect(headers[.contentType] == "application/json")
    }
    do throws(NPSTaxonomyError) {
      _ = try await client.taxonomicSources()
      Issue.record("Malformed JSON must throw.")
    } catch {
      guard case .transport(.decode) = error else {
        Issue.record("Expected decoding failure."); return
      }
    }
    do throws(NPSTaxonomyError) {
      _ = try await client.taxonomicSources()
      Issue.record("Transport cancellation must throw.")
    } catch {
      guard case .transport(.cancelled) = error else {
        Issue.record("Expected cancellation."); return
      }
    }
  }

  @Test("Filtered pages preserve separate basic and profile membership")
  func filteredPages() async throws {
    let basic = try IRMAFixture.taxonomyFilteredSummaries.data()
    let profile = try IRMAFixture.taxonomyFilteredProfiles.data()
    let transport = MockTransport(results: [
      .success(.ok(json: basic)), .success(.ok(json: profile)),
    ])
    let client = NPSTaxonomyClient(transport: transport)
    let search = TaxonSearch.commonName("hawk", category: "Bird", source: "ITIS")
    let summaries = try await client.taxonSummariesResponse(
      query: TaxonSummaryQuery(paging: .page(size: 5, startIndex: 0), search: search))
    let profiles = try await client.taxonProfilesResponse(
      query: TaxonProfileQuery(paging: .page(size: 5, startIndex: 0), search: search))
    #expect(summaries.count == 5 && profiles.count == 5)
    #expect(summaries.first?.scientificName == "Accipiter striatus")
    #expect(summaries.first?.sourceName == "ITIS")
    #expect(profiles.first?.scientificName == "Accipiter bicolor")
    #expect(profiles.first?.classificationSource.code == "ITIS")
    #expect(
      transport.requests.map(\.request.path) == [
        "/taxonomy/v2/rest/searchByCommonName/hawk?category=Bird&detail=basic&format=json&pageSize=5&source=ITIS&startIndex=0",
        "/taxonomy/v2/rest/searchByCommonName/hawk?category=Bird&deriveIfBroken=false&detail=profile&format=json&pageSize=5&source=ITIS&startIndex=0",
      ])
  }

  @Test("Invalid direct inputs fail without transport")
  func invalidInputs() async {
    let transport = MockTransport()
    let client = NPSTaxonomyClient(transport: transport)
    for code in ["", "0", "-1", "2147483648", "81838,1", "١"] {
      do throws(NPSTaxonomyError) {
        _ = try await client.taxonSummary(code: code, kind: .nps)
        Issue.record("Invalid input must throw.")
      } catch {
        guard case .invalidInput = error else { Issue.record("Expected invalidInput."); return }
      }
    }
    #expect(transport.requests.isEmpty)
  }
  @Test("OptionsCategory agrees across all three entry points")
  func optionsCategoryEquivalence() async throws {
    let data = try IRMAFixture.taxonomyOptionsCategory.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomyOptions(kind: .category)
    let a = try await client.taxonomyOptions(kind: .category)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomyOptions(kind: .category))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/urlOptions/category?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("OptionsCodeType agrees across all three entry points")
  func optionsCodeTypeEquivalence() async throws {
    let data = try IRMAFixture.taxonomyOptionsCodeType.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomyOptions(kind: .codeType)
    let a = try await client.taxonomyOptions(kind: .codeType)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomyOptions(kind: .codeType))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/urlOptions/codeType?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("OptionsDetail agrees across all three entry points")
  func optionsDetailEquivalence() async throws {
    let data = try IRMAFixture.taxonomyOptionsDetail.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomyOptions(kind: .detail)
    let a = try await client.taxonomyOptions(kind: .detail)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomyOptions(kind: .detail))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/urlOptions/detail?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("OptionsPaging agrees across all three entry points")
  func optionsPagingEquivalence() async throws {
    let data = try IRMAFixture.taxonomyOptionsPaging.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomyOptions(kind: .paging)
    let a = try await client.taxonomyOptions(kind: .paging)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomyOptions(kind: .paging))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/urlOptions/paging?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("OptionsSource agrees across all three entry points")
  func optionsSourceEquivalence() async throws {
    let data = try IRMAFixture.taxonomyOptionsSource.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomyOptions(kind: .source)
    let a = try await client.taxonomyOptions(kind: .source)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomyOptions(kind: .source))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/urlOptions/source?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("ProfileITIS agrees across all three entry points")
  func profileITISEquivalence() async throws {
    let data = try IRMAFixture.taxonomy81838ITIS.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.taxonProfile(
      code: "81838", kind: .itis, deriveIfBroken: false)
    let a = try await client.taxonProfile(code: "81838", kind: .itis, deriveIfBroken: false)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonProfile(code: "81838", kind: .itis, deriveIfBroken: false))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(
        call.request.path
          == "/taxonomy/v2/rest/81838?codeType=tsn&deriveIfBroken=false&detail=profile&format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("ProfileNPS agrees across all three entry points")
  func profileNPSEquivalence() async throws {
    let data = try IRMAFixture.taxonomy81838NPS.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.taxonProfile(
      code: "81838", kind: .nps, deriveIfBroken: false)
    let a = try await client.taxonProfile(code: "81838", kind: .nps, deriveIfBroken: false)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonProfile(code: "81838", kind: .nps, deriveIfBroken: false))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(
        call.request.path
          == "/taxonomy/v2/rest/81838?codeType=taxoncode&deriveIfBroken=false&detail=profile&format=json"
      )
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Rank agrees across all three entry points")
  func rankEquivalence() async throws {
    let data = try IRMAFixture.taxonomyRankSpecies.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.taxonomicRank(code: "Species")
    let a = try await client.taxonomicRank(code: "Species")
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomicRank(code: "Species"))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/ranks/Species?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Ranks agrees across all three entry points")
  func ranksEquivalence() async throws {
    let data = try IRMAFixture.taxonomyRanks.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomicRanks()
    let a = try await client.taxonomicRanks()
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomicRanks())
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/ranks?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
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
    do throws(NPSTaxonomyError) {
      _ = try await NPSTaxonomyClient(transport: transport).taxonomicSources()
      Issue.record("Redirect must fail.")
    } catch {
      guard case .transport = error else { Issue.record("Expected transport failure."); return }
    }
    #expect(transport.requests.count == 1)
  }

  @Test("ScientificProfiles agrees across all three entry points")
  func scientificProfilesEquivalence() async throws {
    let data = try IRMAFixture.taxonomyScientificProfiles.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonProfilesResponse(
      query: try TaxonProfileQuery(
        search: .scientificName("Pandion haliaetus", category: nil, source: nil)))
    let a = try await client.taxonProfilesResponse(
      query: try TaxonProfileQuery(
        search: .scientificName("Pandion haliaetus", category: nil, source: nil)))
    let b = try await client.value(for: request)
    let c = try await client.send(
      .taxonProfilesResponse(
        query: try TaxonProfileQuery(
          search: .scientificName("Pandion haliaetus", category: nil, source: nil))))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(
        call.request.path
          == "/taxonomy/v2/rest/searchByScientificName/Pandion%20haliaetus?deriveIfBroken=false&detail=profile&format=json"
      )
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("ScientificSummaries agrees across all three entry points")
  func scientificSummariesEquivalence() async throws {
    let data = try IRMAFixture.taxonomyScientificSummaries.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonSummariesResponse(
      query: try TaxonSummaryQuery(
        search: .scientificName("Pandion haliaetus", category: nil, source: nil)))
    let a = try await client.taxonSummariesResponse(
      query: try TaxonSummaryQuery(
        search: .scientificName("Pandion haliaetus", category: nil, source: nil)))
    let b = try await client.value(for: request)
    let c = try await client.send(
      .taxonSummariesResponse(
        query: try TaxonSummaryQuery(
          search: .scientificName("Pandion haliaetus", category: nil, source: nil))))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(
        call.request.path
          == "/taxonomy/v2/rest/searchByScientificName/Pandion%20haliaetus?detail=basic&format=json"
      )
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("SourceCategories agrees across all three entry points")
  func sourceCategoriesEquivalence() async throws {
    let data = try IRMAFixture.taxonomySourceCategories.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.sourceCategories(code: "ITIS")
    let a = try await client.sourceCategories(code: "ITIS")
    let b = try await client.value(for: request)
    let c = try await client.send(.sourceCategories(code: "ITIS"))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/sources/ITIS/categories?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Source agrees across all three entry points")
  func sourceEquivalence() async throws {
    let data = try IRMAFixture.taxonomySourceITIS.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.taxonomicSource(code: "ITIS")
    let a = try await client.taxonomicSource(code: "ITIS")
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomicSource(code: "ITIS"))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/sources/ITIS?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("SourceProfiles agrees across all three entry points")
  func sourceProfilesEquivalence() async throws {
    let data = try IRMAFixture.taxonomySourceProfiles.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomicSourceProfiles()
    let a = try await client.taxonomicSourceProfiles()
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomicSourceProfiles())
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/sources?detail=profile&format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("SourceRanks agrees across all three entry points")
  func sourceRanksEquivalence() async throws {
    let data = try IRMAFixture.taxonomySourceRanks.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.sourceRanks(code: "ITIS")
    let a = try await client.sourceRanks(code: "ITIS")
    let b = try await client.value(for: request)
    let c = try await client.send(.sourceRanks(code: "ITIS"))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/sources/ITIS/ranks?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("Sources agrees across all three entry points")
  func sourcesEquivalence() async throws {
    let data = try IRMAFixture.taxonomySources.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomicSources()
    let a = try await client.taxonomicSources()
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomicSources())
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/sources?detail=basic&format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("SourceTree agrees across all three entry points")
  func sourceTreeEquivalence() async throws {
    let data = try IRMAFixture.taxonomyTreeITIS.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.taxonomicSourceTree(code: "ITIS")
    let a = try await client.taxonomicSourceTree(code: "ITIS")
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomicSourceTree(code: "ITIS"))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/sources/tree/ITIS?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("SourceTrees agrees across all three entry points")
  func sourceTreesEquivalence() async throws {
    let data = try IRMAFixture.taxonomyTrees.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = NPSTaxonomyRequest.taxonomicSourceTrees()
    let a = try await client.taxonomicSourceTrees()
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonomicSourceTrees())
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/sources/tree?format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("SummaryITIS agrees across all three entry points")
  func summaryITISEquivalence() async throws {
    let data = try IRMAFixture.taxonomyBasicITIS.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.taxonSummary(code: "81838", kind: .itis)
    let a = try await client.taxonSummary(code: "81838", kind: .itis)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonSummary(code: "81838", kind: .itis))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(call.request.path == "/taxonomy/v2/rest/81838?codeType=tsn&detail=basic&format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

  @Test("SummaryNPS agrees across all three entry points")
  func summaryNPSEquivalence() async throws {
    let data = try IRMAFixture.taxonomyBasicNPS.data()
    let transport = MockTransport(results: Array(repeating: .success(.ok(json: data)), count: 3))
    let client = NPSTaxonomyClient(transport: transport)
    let request = try NPSTaxonomyRequest.taxonSummary(code: "81838", kind: .nps)
    let a = try await client.taxonSummary(code: "81838", kind: .nps)
    let b = try await client.value(for: request)
    let c = try await client.send(.taxonSummary(code: "81838", kind: .nps))
    #expect(a == b && b == c)
    #expect(transport.requests.count == 3)
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.method == .get)
      #expect(
        call.request.path == "/taxonomy/v2/rest/81838?codeType=taxoncode&detail=basic&format=json")
      #expect(call.request.authority == "irmaservices.nps.gov")
      #expect(
        call.request.headerFields[key] == nil
          && call.request.headerFields[.accept] == "application/json")
    }
  }

}
