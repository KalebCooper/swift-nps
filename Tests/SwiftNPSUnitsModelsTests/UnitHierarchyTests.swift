import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSUnitsModels
import Testing

@Suite("Unit hierarchy", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct UnitHierarchyTests {
  @Test("County objects retain FIPS and ordered unit codes")
  func countyObjectsRetainFIPSAndOrderedUnitCodes() throws {
    let county = try JSONDecoder().decode(
      UnitCounty.self, from: IRMAFixture.unitCountyHancock.data())
    #expect(county.fips == "23009")
    #expect(county.id == 4336)
    #expect(county.unitCodes == ["ACAD"])
    let states = try JSONDecoder().decode([UnitState].self, from: IRMAFixture.unitStates.data())
    #expect(states.first?.fipsCode == "02")
  }

  @Test("Points preserve null coordinates")
  func pointsPreserveNullCoordinates() throws {
    let points = try JSONDecoder().decode([UnitPoint].self, from: IRMAFixture.unitPoints.data())
    #expect(points.contains { $0.latitude == nil })
    #expect(points.first?.code == "ABLI")
    #expect(points.first?.latitude == 37.59900760853723)
    #expect(points.first?.longitude == -85.656723390939)
    let nulls = try JSONDecoder().decode(
      [UnitPoint].self,
      from: Data(#"[{"Code":"X","Latitude":null,"Longitude":null}]"#.utf8))
    #expect(nulls.first?.latitude == nil && nulls.first?.longitude == nil)
  }

  @Test("Selector groups preserve active inactive and indirect leaves")
  func selectorGroupsPreserveActiveInactiveAndIndirectLeaves() throws {
    let nodes = try JSONDecoder().decode([UnitNode].self, from: IRMAFixture.unitSelector.data())
    #expect(nodes.first?.unit.code == "ABLI")
    #expect(nodes.first?.unit.lifecycle == 0)
    #expect(nodes.first?.unit.stateCodes == "KY")
    #expect(nodes.contains { !($0.directInactives ?? []).isEmpty })
    #expect(nodes.contains { !($0.indirectLinks ?? []).isEmpty })
    #expect(nodes.contains { ($0.directLinks ?? []).isEmpty })
    let alaska = try #require(nodes.first { $0.unit.code == "AKR" })
    #expect(alaska.directLinks?.prefix(4).map(\.code) == ["ALAG", "ALEU", "LAKA", "BELA"])
    #expect(alaska.directInactives?.map(\.code) == ["NWAK"])
    let appalachian = try #require(nodes.first { $0.unit.code == "APHN" })
    #expect(appalachian.indirectLinks?.map(\.code) == ["WSOBED"])
    let cumberland = try #require(nodes.first { $0.unit.code == "CUPN" })
    #expect(cumberland.indirectInactives?.map(\.code) == ["FODC", "SHIC", "STRC"])
    #expect(cumberland.regionCode == "SER")
    #expect(nodes.first { $0.unit.code == "AIVC" }?.regionCode == nil)
  }
  @Test("Selector leaf codes and lifecycle values remain open")
  func selectorLeafCodesAndLifecycleValuesRemainOpen() throws {
    var rows = try #require(
      JSONSerialization.jsonObject(with: IRMAFixture.unitSelector.data()) as? [[String: Any]])
    var leaf = try #require(rows[0]["Unit"] as? [String: Any])
    leaf["Lifecycle"] = 99
    leaf["StateCodes"] = NSNull()
    rows[0]["Unit"] = leaf
    rows[0]["DirectLinks"] = []
    let nodes = try JSONDecoder().decode(
      [UnitNode].self, from: JSONSerialization.data(withJSONObject: rows))
    #expect(nodes.first?.unit.lifecycle == 99)
    #expect(nodes.first?.unit.stateCodes == nil)
    #expect(nodes.first?.directLinks == [])
  }

}
