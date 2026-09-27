import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSUnitsModels
import Testing

@Suite("Unit geography", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct UnitGeographyTests {
  @Test("Feature and GML geography remain raw provider text")
  func featureAndGMLGeographyRemainRawProviderText() throws {
    for fixture in [IRMAFixture.unitGeographyFeature, .unitGeographyGML] {
      let data = try fixture.data()
      let rows = try JSONDecoder().decode([UnitGeography].self, from: data)
      let raw = try #require(JSONSerialization.jsonObject(with: data) as? [[String: String]])
      #expect(rows.first?.geography == raw.first?["Geography"])
    }
    let feature = try JSONDecoder().decode(
      [UnitGeography].self, from: IRMAFixture.unitGeographyFeature.data())
    #expect(feature.first?.geography?.hasPrefix("MULTIPOLYGON") == true)
  }

  @Test("Geography preserves WKT text")
  func geographyPreservesWKTText() throws {
    let data = try IRMAFixture.unitAcadiaGeography.data()
    let rows = try JSONDecoder().decode([UnitGeography].self, from: data)
    let raw = try #require(JSONSerialization.jsonObject(with: data) as? [[String: String]])
    #expect(rows.first?.geography == raw.first?["Geography"])
    #expect(rows.first?.geography?.hasPrefix("POLYGON") == true)
  }

  @Test("Geography queries preserve explicit options")
  func geographyQueriesPreserveExplicitOptions() throws {
    let query = try UnitGeographyQuery(
      dataFormat: "wkt", detail: "envelope", searchTerm: "ACAD;YELL")
    #expect(
      UnitEndpoint.unitGeographies(query: query).path
        == "/ACAD%3BYELL/geography?dataformat=wkt&detail=envelope&format=json")
    #expect(
      try UnitEndpoint.unitGeographies(query: UnitGeographyQuery(searchTerm: "ACAD")).path
        == "/ACAD/geography?format=json")
    #expect(throws: UnitGeographyQuery.ValidationError.unsupportedOption) {
      try UnitGeographyQuery(dataFormat: "geojson", searchTerm: "ACAD")
    }
    #expect(throws: UnitGeographyQuery.ValidationError.invalidSearchTerm) {
      try UnitGeographyQuery(searchTerm: "../ACAD")
    }
    #expect(throws: UnitGeographyQuery.ValidationError.self) {
      try UnitGeographyQuery(detail: "unknown", searchTerm: "ACAD")
    }
  }
}
