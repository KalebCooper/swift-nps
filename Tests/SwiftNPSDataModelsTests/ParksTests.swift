import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Parks models and requests", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParksTests {
  @Test("Acadia preserves the recorded envelope and park details")
  func acadiaPreservesTheRecordedEnvelopeAndParkDetails() throws {
    let page = try JSONDecoder().decode(NPSCollection<Park>.self, from: Fixture.parksAcadia.data())
    #expect(page.data.count == 1)
    #expect(page.limit == "1")
    #expect(page.start == "0")
    #expect(page.total == "1")
    let park = try #require(page.data.first)
    #expect(park.fullName == "Acadia National Park")
    #expect(park.id == "6DA17C86-088E-4B4D-B862-7C1BD5CF236B")
    #expect(park.latitude == "44.409286")
    #expect(park.longitude == "-68.247501")
    #expect(park.parkCode == "acad")
    #expect(park.states == "ME")
    #expect(park.entranceFees?.first?.cost == "6.00")
    #expect(park.images?.first?.credit == "Photo courtesy of Sam Mallon, Friends of Acadia")
    #expect(park.operatingHours?.first?.standardHours?["monday"] == "All Day")
    #expect(
      try JSONDecoder().decode(NPSCollection<Park>.self, from: JSONEncoder().encode(page)) == page)
  }

  @Test("An empty recording remains a successful empty page")
  func anEmptyRecordingRemainsASuccessfulEmptyPage() throws {
    let page = try JSONDecoder().decode(NPSCollection<Park>.self, from: Fixture.parksEmpty.data())
    #expect(page.data.isEmpty)
    #expect(page.limit == "1")
    #expect(page.start == "0")
    #expect(page.total == "0")
  }

  @Test("Consumer requests preserve concrete response inference and inspectable resolution")
  func consumerRequestsPreserveConcreteResponseInferenceAndInspectableResolution() throws {
    let request = NPSDataRequest.localAcadia
    let _: NPSDataRequest<ParkNames> = request
    guard case .endpoint(let endpoint) = request.resolution else {
      Issue.record("A single endpoint resolution was expected.")
      return
    }
    let names = try JSONDecoder().decode(ParkNames.self, from: Fixture.parksAcadia.data())
    #expect(names.data.first?.fullName == "Acadia National Park")
    #expect(endpoint.path == "/parks?parkCode=acad&limit=1&start=0")
    #expect(Set([request, .localAcadia]).count == 1)
  }

  @Test("Endpoint links retain encoded queries within the NPS API origin")
  func endpointLinksRetainEncodedQueriesWithinTheNPSAPIOrigin() throws {
    let url = try #require(
      URL(string: "https://DEVELOPER.NPS.GOV:443/api/v1/parks?parkCode=acad&custom=a%2Bb"))
    let endpoint = try #require(Endpoint<ParkNames>(link: url))
    #expect(endpoint.path == "/parks?parkCode=acad&custom=a%2Bb")
  }

  @Test(
    "Endpoint links reject other origins and unsafe paths",
    arguments: [
      "http://developer.nps.gov/api/v1/parks",
      "https://example.com/api/v1/parks",
      "https://developer.nps.gov.example.com/api/v1/parks",
      "https://developer.nps.gov:444/api/v1/parks",
      "https://user:secret@developer.nps.gov/api/v1/parks",
      "https://developer.nps.gov/api/v1/parks#fragment",
      "https://developer.nps.gov/api/v10/parks",
      "https://developer.nps.gov/parks",
      "https://www.nps.gov/acad/index.htm",
      "https://developer.nps.gov/api/v1/%2e%2e/other",
      "https://developer.nps.gov/api/v1/parks?api_key=secret",
    ])
  func endpointLinksRejectOtherOriginsAndUnsafePaths(_ value: String) throws {
    let url = try #require(URL(string: value))
    #expect(Endpoint<NPSCollection<Park>>(link: url) == nil)
  }

  @Test(
    "Endpoint paths reject injection and traversal",
    arguments: [
      "", "parks", "//example.com/parks", "https://example.com/parks",
      "/parks#fragment", "/../parks", "/%2e%2e/parks", "/%2Fexample.com/parks",
      "/parks?api_key=secret", "/parks?API_KEY=secret", "/parks?%61pi_key=secret",
      "/parks\n", "/parks?q=a b", "/%5cother",
    ])
  func endpointPathsRejectInjectionAndTraversal(_ value: String) {
    #expect(Endpoint<NPSCollection<Park>>(path: value) == nil)
  }

  @Test("Missing required park identity fails decoding")
  func missingRequiredParkIdentityFailsDecoding() {
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(
        Park.self, from: Data(#"{"fullName":"Park","name":"Park","parkCode":"zzzz"}"#.utf8))
    }
  }

  @Test("Optional values and unknown provider codes are preserved")
  func optionalValuesAndUnknownProviderCodesArePreserved() throws {
    // Deliberate edge-case JSON, separate from the unmodified recorded responses.
    let data = Data(
      #"""
      {
        "id":"not-a-uuid","fullName":"A future park","name":"Future","parkCode":"future-code",
        "description":null,"latitude":"","longitude":null,"states":"ZZ,XY",
        "addresses":[{"type":"FutureAddress","line2":""}],
        "contacts":{"phoneNumbers":[{"type":"Satellite","extension":null}]},
        "operatingHours":[{"exceptions":null,"standardHours":{"holiday":null}}],
        "unknownFutureField":true
      }
      """#.utf8)
    let park = try JSONDecoder().decode(Park.self, from: data)
    #expect(park.description == nil)
    #expect(park.id == "not-a-uuid")
    #expect(park.latitude == "")
    #expect(park.longitude == nil)
    #expect(park.parkCode == "future-code")
    #expect(park.states == "ZZ,XY")
    #expect(park.addresses?.first?.type == "FutureAddress")
    #expect(park.contacts?.phoneNumbers?.first?.type == "Satellite")
    #expect(park.operatingHours?.first?.exceptions == nil)
    let hours = try #require(park.operatingHours?.first?.standardHours)
    #expect(hours.keys.contains("holiday"))
    #expect(hours["holiday"] == .some(nil))
    #expect(try JSONDecoder().decode(Park.self, from: JSONEncoder().encode(park)) == park)
  }

  @Test(
    "Park codes preserve case and accept unknown identifiers",
    arguments: ["acad", "ACAD", "zzzz", "abc1234567"])
  func parkCodesPreserveCaseAndAcceptUnknownIdentifiers(_ value: String) throws {
    #expect(try ParkCode(value).rawValue == value)
  }

  @Test(
    "Park codes reject invalid single-code syntax",
    arguments: [
      "", "abc", "abcdefghijk", "acad,yell", " acad", "acad ", "a\nbc", "acád", "acad&x=1", "ac/d",
      "a%20",
    ])
  func parkCodesRejectInvalidSingleCodeSyntax(_ value: String) {
    #expect(throws: ParkCode.ValidationError.invalidValue) { try ParkCode(value) }
  }

  @Test("Parks factories infer the same response without annotations")
  func parksFactoriesInferTheSameResponseWithoutAnnotations() throws {
    let code = try ParkCode("acad")
    let endpoint = Endpoint.parks(parkCode: code)
    let request = NPSDataRequest.parks(parkCode: code)
    let _: Endpoint<NPSCollection<Park>> = endpoint
    let _: NPSDataRequest<NPSCollection<Park>> = request
    #expect(endpoint.path == "/parks?parkCode=acad&limit=1&start=0")
    #expect(request.resolution == .endpoint(endpoint))
    #expect(request == NPSDataRequest(endpoint: endpoint))
    #expect(Set([request, .parks(parkCode: code)]).count == 1)
  }

  @Test("The recorded gateway failure preserves its open code")
  func theRecordedGatewayFailurePreservesItsOpenCode() throws {
    let response = try JSONDecoder().decode(
      ServiceErrorResponse.self, from: Fixture.apiKeyMissing.data())
    #expect(response.error.code == "API_KEY_MISSING")
    #expect(response.error.message.hasPrefix("An API key was not provided."))
  }

  @Test("Yellowstone preserves multiple states and dated operating exceptions")
  func yellowstonePreservesMultipleStatesAndDatedOperatingExceptions() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<Park>.self, from: Fixture.parksYellowstone.data())
    let park = try #require(page.data.first)
    #expect(park.fullName == "Yellowstone National Park")
    #expect(park.id == "F58C6D24-8D10-4573-9826-65D42B8B83AD")
    #expect(park.states == "ID,MT,WY")
    #expect(park.latitude == "44.59824417")
    let entrance = try #require(park.operatingHours?.first(where: { $0.name == "West Entrance" }))
    #expect(entrance.exceptions?.first?.startDate == "2027-03-16")
    #expect(entrance.exceptions?.first?.endDate == "2027-04-20")
    #expect(entrance.exceptions?.first?.exceptionHours?["monday"] == "Closed")
  }
}

private struct ParkNames: Decodable, Sendable {
  struct Name: Decodable, Sendable {
    let fullName: String
  }

  let data: [Name]
}

extension NPSDataRequest where Response == ParkNames {
  fileprivate static var localAcadia: Self {
    get {
      guard let endpoint = Endpoint<ParkNames>(path: "/parks?parkCode=acad&limit=1&start=0") else {
        preconditionFailure("The fixed Acadia path is valid.")
      }
      return Self(endpoint: endpoint)
    }
  }
}
