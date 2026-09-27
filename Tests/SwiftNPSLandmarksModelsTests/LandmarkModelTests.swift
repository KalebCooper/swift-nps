import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSLandmarksModels
import Testing

@Suite("Landmark discovery models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct LandmarkModelTests {
  @Test("County relationship identifiers are not substituted")
  func countyIdentifiersRemainDistinct() throws {
    let county = try JSONDecoder().decode(
      LandmarkCounty.self, from: IRMAFixture.landmarkCountyMaine.data())
    #expect(county.countyID == 4347)
    #expect(county.id == 212)
    #expect(county.stateCode == "ME")
    let all = try JSONDecoder().decode(
      LandmarkCounty.self, from: IRMAFixture.landmarkCountyAll.data())
    #expect(all.code == "VICO-VA" && all.countyID == 5939 && all.id == 435)
    let wy = try JSONDecoder().decode(
      LandmarkCounty.self, from: IRMAFixture.landmarkCountyWyoming.data())
    #expect(wy.countyID == 6256 && wy.id == 72)
  }

  @Test("County search has an enriched shape distinct from ordinary detail")
  func countySearchHasAnEnrichedShape() throws {
    let rows = try JSONDecoder().decode(
      [LandmarkWithCounty].self, from: IRMAFixture.landmarkPerCounty.data())
    let row = try #require(rows.first)
    #expect(row.code == "CRBO-ME" && row.countyID == 4347 && row.id == 212)
    #expect(row.countyLabel == "Aroostook County")
    #expect(row.stateCode == nil && row.authoritativeURL == nil)
  }

  @Test("Decimal acreage and omitted optional fields remain representable")
  func decimalAcreageAndOptionalFields() throws {
    let objects = try #require(
      JSONSerialization.jsonObject(with: IRMAFixture.landmarkAppleton.data()) as? [[String: Any]])
    var object = try #require(objects.first)
    object["Area_Acres"] = 12.75
    object["AuthoritativeURL"] = "https://example.org/landmark"
    let decoder = JSONDecoder()
    let value = try decoder.decode(
      NPSLandmark.self, from: JSONSerialization.data(withJSONObject: object))
    #expect(value.areaAcres == 12.75 && value.authoritativeURL == "https://example.org/landmark")
    object.removeValue(forKey: "AuthoritativeURL")
    object.removeValue(forKey: "SecondaryState")
    let omitted = try decoder.decode(
      NPSLandmark.self, from: JSONSerialization.data(withJSONObject: object))
    #expect(omitted.authoritativeURL == nil && omitted.secondaryState == nil)
    #expect(try decoder.decode(NPSLandmark.self, from: JSONEncoder().encode(value)) == value)
  }

  @Test("Landmark detail preserves raw states and nullable URLs")
  func landmarkDetailPreservesRawStates() throws {
    let me = try JSONDecoder().decode([NPSLandmark].self, from: IRMAFixture.landmarkMaine.data())
    #expect(me.count == 14 && me.first?.id == 4827)
    #expect(me.first?.areaAcres == 630 && me.first?.authoritativeURL == nil)
    let wy = try JSONDecoder().decode([NPSLandmark].self, from: IRMAFixture.landmarkWyoming.data())
    #expect(wy.first(where: { $0.code == "SACR-WY" })?.secondaryState == "CO")
  }

  @Test("Unknown states use the service vocabulary")
  func unknownStatesUseServiceVocabulary() throws {
    let rows = try JSONDecoder().decode(
      [LandmarkState].self, from: IRMAFixture.landmarkStates.data())
    #expect(
      rows.count == 56 && rows.contains(where: { $0.stateCode == "--" && $0.label == "Unknown" }))
    let unknown = try JSONDecoder().decode(
      LandmarkState.self, from: IRMAFixture.landmarkStateUnknown.data())
    #expect(unknown.stateCode == "--")
  }
}
