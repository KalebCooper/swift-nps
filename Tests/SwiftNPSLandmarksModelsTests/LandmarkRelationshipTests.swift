import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSLandmarksModels
import Testing

@Suite("Landmark relationships", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct LandmarkRelationshipTests {
  @Test("Enriched rows retain zero county IDs and null classifications")
  func enrichedRowsRetainProviderValues() throws {
    let rows = try JSONDecoder().decode(
      [LandmarkWithCounty].self, from: IRMAFixture.landmarkWithCounty.data())
    let row = try #require(rows.first)
    #expect(row.id == 4827 && row.countyID == 0)
    #expect(row.authoritativeURL == nil && row.countyLabel == nil && row.stateCode == nil)
    let filtered = try JSONDecoder().decode(
      [LandmarkWithCounty].self, from: IRMAFixture.landmarkWithCountyFiltered.data())
    #expect(filtered.first?.countyID == 4347 && filtered.first?.countyLabel == "Aroostook County")
  }

  @Test("Flat index retains repeated membership without invented nesting")
  func flatIndexRetainsRepeatedMembership() throws {
    let rows = try JSONDecoder().decode(
      [LandmarkStateGroup].self, from: IRMAFixture.landmarkStateIndex.data())
    #expect(rows.count == 613 && rows.first?.siteCode == "BECR-AL")
    let repeated = rows.filter { $0.siteCode == "SACR-WY" }
    #expect(repeated.count == 2 && Set(repeated.map(\.stateCode)) == ["CO", "WY"])
    let duplicates = rows.filter { $0.siteCode == "ANRI-MN" }
    #expect(duplicates.count == 2)
  }

  @Test("A landmark retains multiple county relationships")
  func landmarkRetainsMultipleCounties() throws {
    let rows = try JSONDecoder().decode(
      [LandmarkCounty].self, from: IRMAFixture.landmarkAppletonCounties.data())
    #expect(rows.map(\.countyID) == [4351, 4352])
    #expect(rows.map(\.id) == [4827, 4827])
    #expect(rows.allSatisfy { $0.code == "APBO-ME" })
    let wy = try JSONDecoder().decode(
      [LandmarkCounty].self, from: IRMAFixture.landmarkSiteWyoming.data())
    #expect(wy.count == 7)
  }

  @Test("Owner classifications preserve multiple and unknown categories")
  func ownersRetainUnknownCategories() throws {
    let owners = try JSONDecoder().decode(
      [LandmarkOwner].self, from: IRMAFixture.landmarkOwnerMultiple.data())
    #expect(owners.map(\.id) == [75, 75, 75])
    #expect(owners.map(\.ownerTypeID) == [1, 2, 3])
    #expect(owners.map(\.ownerTypeLabel) == ["Private", "Federal", "State"])
    let owner = try JSONDecoder().decode(
      LandmarkOwner.self,
      from: Data(#"{"ID":212,"OwnerTypeId":99,"OwnerTypeLabel":"Future category"}"#.utf8))
    #expect(owner.id == 212 && owner.ownerTypeID == 99 && owner.ownerTypeLabel == "Future category")
  }

  @Test("Relationship queries expose only supported filters")
  func relationshipQueriesExposeSupportedFilters() throws {
    let owner = try LandmarkOwnerQuery(code: "APBO-ME", id: 4827)
    #expect(
      NPSLandmarksRequest.landmarkOwners(query: owner).endpoint.path
        == "/api/LandmarkOwnerInformation?Code=APBO-ME&ID=4827")
    let county = try LandmarkStateCountyQuery(countyID: 4347, stateCode: "ME")
    #expect(
      NPSLandmarksRequest.landmarkStateCounties(query: county).endpoint.path
        == "/api/StateCounty?CountyID=4347&StateCode=ME")
    let query = try LandmarkQuery(code: "APBO-ME", countyID: 4351, id: 4827, stateCode: "ME")
    #expect(
      NPSLandmarksRequest.landmarkSiteCounties(query: query).endpoint.path
        == "/api/SiteCounties?Code=APBO-ME&CountyID=4351&ID=4827&StateCode=ME")
    #expect(
      NPSLandmarksRequest.landmarksWithCounty(query: query).endpoint.path
        == "/api/LandmarkInformationWithCounty?Code=APBO-ME&CountyID=4351&ID=4827&StateCode=ME")
    #expect(
      NPSLandmarksRequest.landmarkOwners(query: try LandmarkOwnerQuery()).endpoint.path
        == "/api/LandmarkOwnerInformation")
    #expect(
      NPSLandmarksRequest.landmarkStateCounties(query: try LandmarkStateCountyQuery()).endpoint.path
        == "/api/StateCounty")
  }

  @Test("Relationship query bounds prevent silent filter broadening")
  func relationshipQueryBounds() throws {
    for id: Int64 in [0, -1, Int64(Int32.max) + 1, .max] {
      #expect(throws: LandmarkQuery.ValidationError.invalidIdentifier) {
        try LandmarkOwnerQuery(id: id)
      }
      #expect(throws: LandmarkQuery.ValidationError.invalidIdentifier) {
        try LandmarkStateCountyQuery(countyID: id)
      }
    }
    #expect(throws: LandmarkQuery.ValidationError.invalidText) { try LandmarkOwnerQuery(code: "") }
    #expect(throws: LandmarkQuery.ValidationError.invalidText) {
      try LandmarkStateCountyQuery(stateCode: "\n")
    }
    #expect(try LandmarkOwnerQuery(id: Int64(Int32.max)).id == Int64(Int32.max))
  }

  @Test("State counties have their own labels and no landmark identifier")
  func stateCountiesPreserveLabels() throws {
    let rows = try JSONDecoder().decode(
      [LandmarkStateCounty].self, from: IRMAFixture.landmarkStateCounties.data())
    #expect(rows.count == 16)
    #expect(rows.first?.countyID == 4346 && rows.first?.countyLabel == "Androscoggin County")
    #expect(rows.first?.displayLabel == "Androscoggin" && rows.first?.stateLabel == "Maine")
  }
}
