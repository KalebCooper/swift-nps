import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSUnitsModels
import Testing

@Suite("Unit models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct UnitModelTests {
  @Test("Catalog objects retain original summaries")
  func catalogObjectsRetainOriginalSummaries() throws {
    let designation = try JSONDecoder().decode(
      UnitDesignation.self, from: IRMAFixture.unitDesignation.data())
    #expect(designation.code == "NP")
    #expect(designation.units.first?.code == "ACAD")
    let subtype = try JSONDecoder().decode(UnitSubtype.self, from: IRMAFixture.unitSubtype.data())
    #expect(subtype.code == "OP")
    #expect(subtype.units.map(\.code) == ["NPS"])
  }

  @Test("National administrative profiles retain null fields")
  func nationalAdministrativeProfilesRetainNullFields() throws {
    let rows = try JSONDecoder().decode([NPSUnit].self, from: IRMAFixture.unitNational.data())
    let unit = try #require(rows.first)
    #expect(unit.unitCode == "NPS")
    #expect(unit.network == nil && unit.region == nil && unit.stateCodes == nil)
    #expect(unit.unitDesignationCode == nil && unit.unitDesignationName == nil)
  }

  @Test("Searches preserve provider ordering and multi state arrays")
  func searchesPreserveProviderOrderingAndMultiStateArrays() throws {
    let rows = try JSONDecoder().decode([NPSUnit].self, from: IRMAFixture.unitMultiple.data())
    #expect(rows.map(\.unitCode) == ["ACAD", "YELL"])
    #expect(rows.last?.stateCodes == ["ID", "MT", "WY"])
    let semicolon = try JSONDecoder().decode([NPSUnit].self, from: IRMAFixture.unitSemicolon.data())
    #expect(rows == semicolon)
  }

  @Test("Unit profiles retain administrative links and state arrays")
  func unitProfilesRetainAdministrativeLinksAndStateArrays() throws {
    let units = try JSONDecoder().decode([NPSUnit].self, from: IRMAFixture.unitAcadia.data())
    let unit = try #require(units.first)
    #expect(unit.unitCode == "ACAD")
    #expect(unit.network == "NETN")
    #expect(unit.stateCodes == ["ME"])
  }

  @Test("Unknown lifecycle and designation values remain open text")
  func unknownLifecycleAndDesignationValuesRemainOpenText() throws {
    var value = try #require(
      JSONSerialization.jsonObject(with: IRMAFixture.unitAcadia.data()) as? [[String: Any]])
    value[0]["UnitLifecycle"] = "Future status"
    value[0]["UnitDesignationCode"] = "FUTURE"
    value[0].removeValue(forKey: "Region")
    let rows = try JSONDecoder().decode(
      [NPSUnit].self, from: JSONSerialization.data(withJSONObject: value))
    #expect(rows.first?.unitLifecycle == "Future status")
    #expect(rows.first?.unitDesignationCode == "FUTURE")
    #expect(rows.first?.region == nil)
  }
}
