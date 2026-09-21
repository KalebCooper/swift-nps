import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Road events models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct RoadEventTests {
  @Test("An empty recorded feed keeps its metadata and no features")
  func anEmptyRecordedFeedKeepsItsMetadataAndNoFeatures() throws {
    let feed = try decode(.roadEventsEmpty)
    #expect(feed.type == "FeatureCollection")
    #expect(feed.features == [])
    let info = try #require(feed.roadEventFeedInfo)
    #expect(info.contactEmail == "asknps@nps.gov")
    #expect(info.contactName == "National Park Service")
    #expect(info.dataSources == [])
    #expect(info.id == "6ba84a20-3be7-4df0-81eb-711eccf84f18")
    #expect(info.license == "https://creativecommons.org/publicdomain/zero/1.0/")
    #expect(info.publisher == "National Park Service")
    #expect(info.updateDate == "2024-01-16T16:49:30.901071Z")
    #expect(info.updateFrequency == 60)
    #expect(info.version == "4.1")
  }

  @Test("Both feature identifiers are preserved under distinct properties")
  func bothFeatureIdentifiersArePreservedUnderDistinctProperties() throws {
    let features = try #require(decode(.roadEventsYellowstone).features)
    #expect(
      features.map(\.properties?.id) == [
        "36856bd9-bccd-34b6-452c-4384c3dc9277", "f15141d8-695c-ef76-0e74-804b56bba982",
      ])
    #expect(features.map(\.properties?.numericId) == [0, 1])
  }

  @Test("Constructed features decode with nulls and unknown fields")
  func constructedFeaturesDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded features never send null values.
    let json = Data(
      #"""
      {"type":null,"geometry":{"type":null,"coordinates":null,"bbox":[0]},
      "properties":{"Id":null,"_id":null,"core_details":null,"types_of_work":null,
      "types_of_incident":null,"end_date":null,"future_field":{"nested":true}}}
      """#.utf8)
    let feature = try JSONDecoder().decode(RoadEventFeature.self, from: json)
    #expect(feature.type == nil)
    #expect(feature.geometry?.coordinates == nil)
    #expect(feature.geometry?.type == nil)
    let details = try #require(feature.properties)
    #expect(details.id == nil)
    #expect(details.numericId == nil)
    #expect(details.coreDetails == nil)
    #expect(details.typesOfWork == nil)
    #expect(details.typesOfIncident == nil)
    #expect(details.endDate == nil)
  }

  @Test("A feature nested deeper than a line of positions keeps its coordinates")
  func aFeatureNestedDeeperThanALineOfPositionsKeepsItsCoordinates() throws {
    // Constructed, not recorded: every recorded feature is a LineString. A feed carrying one
    // feature of another shape must still decode in full.
    let json = Data(
      #"""
      {"type":"Feature","geometry":{"type":"Polygon","coordinates":[[[1.5,2.5],[3.5,4.5]]]},
      "properties":{"Id":"a"}}
      """#.utf8)
    let feature = try JSONDecoder().decode(RoadEventFeature.self, from: json)
    #expect(feature.geometry?.lineString == nil)
    #expect(feature.geometry?.polygon == [[[1.5, 2.5], [3.5, 4.5]]])
    #expect(feature.properties?.id == "a")
  }

  @Test("Incidents and work zones decode from a populated recorded feed")
  func incidentsAndWorkZonesDecodeFromAPopulatedRecordedFeed() throws {
    let feed = try decode(.roadEventsDelawareWaterGap)
    let features = try #require(feed.features)
    #expect(features.count == 8)
    #expect(features.map(\.properties?.numericId) == [0, 1, 2, 3, 4, 5, 6, 7])
    #expect(
      features.map(\.properties?.coreDetails?.eventType) == [
        "work-zone", "work-zone", "work-zone", "work-zone",
        "incident", "incident", "incident", "incident",
      ])
    let source = try #require(feed.roadEventFeedInfo?.dataSources?.first)
    #expect(source.contactEmail == "dewa_Superintendent@nps.gov")
    #expect(source.contactName == "Delaware Water Gap")
    #expect(source.dataSourceId == "c8a6b124-d7a0-49fd-2c61-08d4c7ad36e2")
    #expect(source.organizationName == "Delaware Water Gap")
    #expect(source.updateDate == "2025-05-13T16:22:17.178633Z")

    let workZone = try #require(features.first)
    #expect(workZone.type == "Feature")
    #expect(workZone.geometry?.type == "LineString")
    #expect(workZone.geometry?.lineString?.count == 67)
    #expect(workZone.geometry?.lineString?.first == [-74.8159821, 41.2871847])
    let work = try #require(workZone.properties)
    #expect(work.id == "19dc202e-1b68-e3d6-45b1-ccfa6668250b")
    #expect(work.typesOfWork?.map(\.typeName) == ["surface-work"])
    #expect(work.typesOfIncident == nil)
    #expect(work.startDate == "2026-04-06T04:00:00Z")
    #expect(work.endDate == nil)
    #expect(work.endDateAccuracy == "estimated")
    #expect(work.vehicleImpact == "all-lanes-closed")
    #expect(work.coreDetails?.name == "Old Mine Road Between Jager Road and Route 206")
    #expect(work.coreDetails?.dataSourceId == source.dataSourceId)
    #expect(work.coreDetails?.direction == "northbound")
    #expect(work.coreDetails?.roadNames == ["Old Mine Road"])

    let incident = try #require(features[4].properties)
    #expect(incident.id == "2557b97e-0b25-60f2-ef89-5d36d21c2cd3")
    #expect(incident.typesOfWork == nil)
    #expect(incident.startDate == "2023-05-31T16:48:00Z")
    #expect(incident.coreDetails?.name == "Road Closures in New Jersey")
    #expect(incident.coreDetails?.roadNames == ["Main Street and Route 615"])
    let classification = try #require(incident.typesOfIncident?.first)
    #expect(incident.typesOfIncident?.count == 1)
    #expect(classification.incidentCategory == "crash")
    #expect(classification.incidentType == "crash")
    #expect(
      classification.description
        == "The bridge on Main Street in Walpack Center is closed indefinitely due to structural"
        + " damage from a vehicle collision.\n\nRoute 615 is closed in Flatbrookville due to"
        + " landslide and active slope failure.")
    #expect(features[4].geometry?.lineString?.first == [-74.876741, 41.1571551])
  }

  @Test("A small recorded feed keeps every property as sent")
  func aSmallRecordedFeedKeepsEveryPropertyAsSent() throws {
    let feed = try decode(.roadEventsYellowstone)
    #expect(feed.type == "FeatureCollection")
    #expect(
      feed.roadEventFeedInfo?.dataSources?.map(\.organizationName) == [
        "Yellowstone National Park"
      ])
    let features = try #require(feed.features)
    #expect(features.count == 2)
    #expect(
      features[0].geometry?.lineString == [
        [-110.6791841, 44.9579849], [-110.6792844, 44.9580566],
      ])
    #expect(
      features[1].geometry?.lineString == [
        [-110.6792844, 44.9580566], [-110.6791841, 44.9579849],
      ])
    let details = try #require(features[0].properties)
    #expect(details.beginningAccuracy == "estimated")
    #expect(details.endDate == "2026-11-01T05:59:59Z")
    #expect(details.endDateAccuracy == "estimated")
    #expect(details.endingAccuracy == "estimated")
    #expect(details.isEndDateVerified == false)
    #expect(details.isEndPositionVerified == false)
    #expect(details.isStartDateVerified == false)
    #expect(details.isStartPositionVerified == false)
    #expect(details.locationMethod == "unknown")
    #expect(details.startDate == "2026-04-01T06:00:00Z")
    #expect(details.startDateAccuracy == "estimated")
    #expect(details.typesOfWork?.map(\.typeName) == ["barrier-work"])
    #expect(details.vehicleImpact == "alternating-one-way")
    #expect(details.coreDetails?.eventType == "work-zone")
    #expect(details.coreDetails?.direction == "westbound")
    #expect(details.coreDetails?.roadNames == [])
    #expect(details.coreDetails?.name == "Traffic Delays - Gardner River High Bridge")
    #expect(
      details.coreDetails?.description?.hasSuffix(
        #"(8'6"+ wide, 75'+ long, 80,000 lbs+ gross vehicle weight) will be able to cross."#)
        == true)
    #expect(features[1].properties?.coreDetails?.direction == "eastbound")
  }

  @Test("A type filtered recording decodes identically to the unfiltered park feed")
  func aTypeFilteredRecordingDecodesIdenticallyToTheUnfilteredParkFeed() throws {
    #expect(try decode(.roadEventsType) == decode(.roadEventsYellowstone))
  }

  @Test(
    "Every event type encodes the provider's spelling",
    arguments: [
      (RoadEventType.detour, "Detour"), (.incident, "Incident"),
      (.restriction, "Restriction"), (.workZone, "WorkZone"),
    ])
  func everyEventTypeEncodesTheProvidersSpelling(_ type: RoadEventType, _ spelling: String) {
    #expect(type.rawValue == spelling)
    #expect(Endpoint.roadEvents(type: type).path == "/roadevents?type=" + spelling)
  }

  @Test("Road event endpoints send only the parameters supplied")
  func roadEventEndpointsSendOnlyTheParametersSupplied() throws {
    let code = try ParkCode("yell")
    #expect(Endpoint.roadEvents().path == "/roadevents")
    #expect(Endpoint.roadEvents(parkCode: code).path == "/roadevents?parkCode=yell")
    #expect(
      Endpoint.roadEvents(parkCode: code, type: .workZone).path
        == "/roadevents?parkCode=yell&type=WorkZone")
  }

  @Test("Road event requests resolve to their endpoint")
  func roadEventRequestsResolveToTheirEndpoint() throws {
    let code = try ParkCode("yell")
    let request = NPSDataRequest.roadEvents(parkCode: code, type: .workZone)
    #expect(request == NPSDataRequest(endpoint: .roadEvents(parkCode: code, type: .workZone)))
    guard case .endpoint(let endpoint) = request.resolution else {
      Issue.record("A road events request resolves to one endpoint.")
      return
    }
    #expect(endpoint.path == "/roadevents?parkCode=yell&type=WorkZone")
    #expect(NPSDataRequest.roadEvents() != request)
  }

  private func decode(_ fixture: Fixture) throws -> RoadEventFeed {
    try JSONDecoder().decode(RoadEventFeed.self, from: fixture.data())
  }
}
