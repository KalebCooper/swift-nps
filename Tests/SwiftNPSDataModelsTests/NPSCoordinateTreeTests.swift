import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Coordinate trees and geometry", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSCoordinateTreeTests {
  @Test("An empty array decodes as an empty list that both accessors accept")
  func anEmptyArrayDecodesAsAnEmptyListThatBothAccessorsAccept() throws {
    #expect(try tree("[]") == .nested([]))
    #expect(try geometry("Polygon", "[]").polygon == [])
    #expect(try geometry("MultiPolygon", "[]").multiPolygon == [])
    #expect(try tree("[[]]") == .nested([.nested([])]))
    #expect(try geometry("Polygon", "[[]]").polygon == [[]])
    #expect(try geometry("MultiPolygon", "[[]]").multiPolygon == [[]])
  }

  @Test("A four level MultiPolygon reads every polygon, ring, and position")
  func aFourLevelMultiPolygonReadsEveryPolygonRingAndPosition() throws {
    let polygons = try geometry(
      "MultiPolygon",
      "[[[[1.5,2.5],[3.5,4.5],[1.5,2.5]],[[5.5,6.5],[7.5,8.5],[5.5,6.5]]],[[[9.5,10.5]]]]"
    ).multiPolygon
    #expect(
      polygons == [
        [[[1.5, 2.5], [3.5, 4.5], [1.5, 2.5]], [[5.5, 6.5], [7.5, 8.5], [5.5, 6.5]]],
        [[[9.5, 10.5]]],
      ])
  }

  @Test("An empty list is never accepted where a position belongs")
  func anEmptyListIsNeverAcceptedWhereAPositionBelongs() throws {
    #expect(try geometry("Polygon", "[[[]]]").polygon == nil)
    #expect(try geometry("MultiPolygon", "[[[[]]]]").multiPolygon == nil)
  }

  @Test("A LineString reads its positions in the order sent")
  func aLineStringReadsItsPositionsInTheOrderSent() throws {
    let line = try geometry("LineString", "[[1.5,2.5],[3.5,4.5],[5.5,6.5]]")
    #expect(line.lineString == [[1.5, 2.5], [3.5, 4.5], [5.5, 6.5]])
    #expect(line.polygon == nil)
    #expect(line.multiPolygon == nil)
    #expect(try geometry("LineString", "[]").lineString == [])
  }

  @Test("Accessors return nil when the depth does not match the declared type")
  func accessorsReturnNilWhenTheDepthDoesNotMatchTheDeclaredType() throws {
    #expect(try geometry("LineString", "[[[1.5,2.5]]]").lineString == nil)
    #expect(try geometry("LineString", "[1.5,2.5]").lineString == nil)
    #expect(try geometry("Polygon", "[[[[1.5,2.5]]]]").polygon == nil)
    #expect(try geometry("Polygon", "[[1.5,2.5]]").polygon == nil)
    #expect(try geometry("MultiPolygon", "[[[1.5,2.5]]]").multiPolygon == nil)
    #expect(try geometry("MultiPolygon", "[1.5,2.5]").multiPolygon == nil)
  }

  @Test("Accessors return nil when the declared type differs")
  func accessorsReturnNilWhenTheDeclaredTypeDiffers() throws {
    let rings = try geometry("MultiPolygon", "[[[1.5,2.5]]]")
    #expect(rings.polygon == nil)
    let polygons = try geometry("Polygon", "[[[[1.5,2.5]]]]")
    #expect(polygons.multiPolygon == nil)
    #expect(try geometry("polygon", "[[[1.5,2.5]]]").polygon == nil)
    #expect(try geometry("MultiLineString", "[[1.5,2.5]]").lineString == nil)
  }

  @Test("Accessors return nil when the type or coordinates are missing")
  func accessorsReturnNilWhenTheTypeOrCoordinatesAreMissing() throws {
    let untyped = try JSONDecoder().decode(
      NPSGeometry.self, from: Data(#"{"coordinates":[[[1.5,2.5]]]}"#.utf8))
    #expect(untyped.type == nil)
    #expect(untyped.lineString == nil)
    #expect(untyped.polygon == nil)
    #expect(untyped.multiPolygon == nil)
    let empty = try JSONDecoder().decode(
      NPSGeometry.self, from: Data(#"{"type":"Polygon","coordinates":null}"#.utf8))
    #expect(empty.coordinates == nil)
    #expect(empty.polygon == nil)
  }

  @Test("Integer tokens decode as the same whole numbers")
  func integerTokensDecodeAsTheSameWholeNumbers() throws {
    #expect(try tree("[-81,24]") == .position([-81, 24]))
    #expect(try tree("[-81,24]") == tree("[-81.0,24.0]"))
  }

  @Test("Mixed depths in one tree decode and round trip but fail both accessors")
  func mixedDepthsInOneTreeDecodeAndRoundTripButFailBothAccessors() throws {
    let json = "[[[1.5,2.5]],[1.5,2.5]]"
    let mixed = try tree(json)
    #expect(
      mixed == .nested([.nested([.position([1.5, 2.5])]), .position([1.5, 2.5])]))
    #expect(try geometry("Polygon", json).polygon == nil)
    #expect(try geometry("MultiPolygon", json).multiPolygon == nil)
    let encoded = try JSONEncoder().encode(mixed)
    #expect(try JSONDecoder().decode(NPSCoordinateTree.self, from: encoded) == mixed)
  }

  @Test(
    "Values that are not coordinate arrays fail to decode",
    arguments: [
      #""text""#, #"{"x":1}"#, "true", "null", "1.5", "[1.5,[2.5]]", "[[1.5],2.5]",
      "[null]", #"["1.5"]"#, "[true]", "[true,false]",
    ])
  func valuesThatAreNotCoordinateArraysFailToDecode(_ json: String) {
    #expect(throws: DecodingError.self) { try tree(json) }
  }

  @Test("An empty position encodes as an empty array that decodes as an empty list")
  func anEmptyPositionEncodesAsAnEmptyArrayThatDecodesAsAnEmptyList() throws {
    let encoded = try JSONEncoder().encode(NPSCoordinateTree.position([]))
    #expect(String(decoding: encoded, as: UTF8.self) == "[]")
    #expect(try JSONDecoder().decode(NPSCoordinateTree.self, from: encoded) == .nested([]))
  }

  @Test("Positions keep two or three numbers as sent")
  func positionsKeepTwoOrThreeNumbersAsSent() throws {
    let rings = try geometry("Polygon", "[[[1.5,2.5],[3.5,4.5,120.25]]]").polygon
    #expect(rings == [[[1.5, 2.5], [3.5, 4.5, 120.25]]])
  }

  @Test("Unknown geometry types keep their coordinates without typed accessors")
  func unknownGeometryTypesKeepTheirCoordinatesWithoutTypedAccessors() throws {
    let unnamed = try geometry("GeometryCollection", "[[1.5,2.5],[3.5,4.5]]")
    #expect(unnamed.type == "GeometryCollection")
    #expect(unnamed.coordinates == .nested([.position([1.5, 2.5]), .position([3.5, 4.5])]))
    #expect(unnamed.lineString == nil)
    #expect(unnamed.polygon == nil)
    #expect(unnamed.multiPolygon == nil)
    let encoded = try JSONEncoder().encode(unnamed)
    #expect(try JSONDecoder().decode(NPSGeometry.self, from: encoded) == unnamed)
  }

  private func geometry(_ type: String, _ coordinates: String) throws -> NPSGeometry {
    let json = #"{"type":""# + type + #"","coordinates":"# + coordinates + "}"
    return try JSONDecoder().decode(NPSGeometry.self, from: Data(json.utf8))
  }

  private func tree(_ json: String) throws -> NPSCoordinateTree {
    try JSONDecoder().decode(NPSCoordinateTree.self, from: Data(json.utf8))
  }
}
