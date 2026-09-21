import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Shared shapes", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct SharedShapeTests {
  @Test("A crop keeps a string aspect ratio exactly as sent")
  func aCropKeepsAStringAspectRatioExactlyAsSent() throws {
    let crop = try JSONDecoder().decode(
      NPSImageCrop.self,
      from: Data(#"{"aspectRatio":"1.78","url":"https://example.invalid/a"}"#.utf8))
    #expect(crop.aspectRatio == "1.78")
    #expect(crop.ratio == 1.78)
    #expect(crop.url == "https://example.invalid/a")
  }

  @Test("A crop stores a number aspect ratio as its decimal text")
  func aCropStoresANumberAspectRatioAsItsDecimalText() throws {
    let integral = try JSONDecoder().decode(
      NPSImageCrop.self, from: Data(#"{"aspectRatio":1.00,"url":null}"#.utf8))
    #expect(integral.aspectRatio == "1.0")
    #expect(integral.ratio == 1.0)
    #expect(integral.url == nil)
    let fractional = try JSONDecoder().decode(
      NPSImageCrop.self, from: Data(#"{"aspectRatio":1.78}"#.utf8))
    #expect(fractional.aspectRatio == "1.78")
    #expect(fractional.ratio == 1.78)
  }

  @Test("A crop with a null or missing aspect ratio has no ratio")
  func aCropWithANullOrMissingAspectRatioHasNoRatio() throws {
    let null = try JSONDecoder().decode(
      NPSImageCrop.self, from: Data(#"{"aspectRatio":null,"url":null}"#.utf8))
    #expect(null.aspectRatio == nil)
    #expect(null.ratio == nil)
    let missing = try JSONDecoder().decode(NPSImageCrop.self, from: Data("{}".utf8))
    #expect(missing.aspectRatio == nil)
    #expect(missing.ratio == nil)
  }

  @Test("A non-numeric aspect ratio is kept but has no ratio")
  func aNonNumericAspectRatioIsKeptButHasNoRatio() throws {
    let crop = try JSONDecoder().decode(
      NPSImageCrop.self, from: Data(#"{"aspectRatio":"wide"}"#.utf8))
    #expect(crop.aspectRatio == "wide")
    #expect(crop.ratio == nil)
  }

  @Test("A crop with a non-text, non-number aspect ratio fails to decode")
  func aCropWithANonTextNonNumberAspectRatioFailsToDecode() {
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(NPSImageCrop.self, from: Data(#"{"aspectRatio":[1]}"#.utf8))
    }
  }

  @Test("A crop round-trips through Codable as text")
  func aCropRoundTripsThroughCodableAsText() throws {
    let crop = try JSONDecoder().decode(
      NPSImageCrop.self, from: Data(#"{"aspectRatio":3,"url":"u"}"#.utf8))
    let encoded = try JSONEncoder().encode(crop)
    let decoded = try JSONDecoder().decode(NPSImageCrop.self, from: encoded)
    #expect(decoded == crop)
    #expect(decoded.aspectRatio == "3.0")
  }

  @Test("One image type decodes constructed full and url-only variants")
  func oneImageTypeDecodesConstructedFullAndUrlOnlyVariants() throws {
    let full = try JSONDecoder().decode(
      NPSImage.self,
      from: Data(
        #"""
        {"altText":"a","caption":"c","credit":"n","crops":[],"description":"","title":"t",
        "url":"u"}
        """#.utf8))
    #expect(full.description == "")
    #expect(full.crops == [])
    let urlOnly = try JSONDecoder().decode(NPSImage.self, from: Data(#"{"url":"u"}"#.utf8))
    #expect(urlOnly.url == "u")
    #expect(urlOnly.altText == nil)
    #expect(urlOnly.crops == nil)
    #expect(urlOnly.description == nil)
  }

  @Test("A related park keeps every field as sent")
  func aRelatedParkKeepsEveryFieldAsSent() throws {
    let park = try JSONDecoder().decode(
      NPSRelatedPark.self,
      from: Data(
        #"""
        {"designation":"","fullName":"Acadia National Park","name":"Acadia","parkCode":"acad",
        "states":"ME,NH\r\n","url":"","extra":1}
        """#.utf8))
    #expect(park.designation == "")
    #expect(park.fullName == "Acadia National Park")
    #expect(park.name == "Acadia")
    #expect(park.parkCode == "acad")
    #expect(park.states == "ME,NH\r\n")
    #expect(park.url == "")
  }

  @Test("An amenity park entry encodes as one flat object")
  func anAmenityParkEntryEncodesAsOneFlatObject() throws {
    let entry = try JSONDecoder().decode(
      AmenityParkPlaces.RelatedPark.self,
      from: Data(#"{"parkCode":"acad","places":[{"id":"p","title":"t","url":"u"}]}"#.utf8))
    let encoded = try JSONDecoder().decode(
      [String: JSONValue].self, from: try JSONEncoder().encode(entry))
    #expect(encoded["parkCode"] == .string("acad"))
    #expect(encoded["places"] != nil)
    let centers = try JSONDecoder().decode(
      AmenityParkVisitorCenters.RelatedPark.self,
      from: Data(#"{"parkCode":"acad","visitorcenters":[{"id":"v","name":"n","url":"u"}]}"#.utf8))
    let reencoded = try JSONDecoder().decode(
      [String: JSONValue].self, from: try JSONEncoder().encode(centers))
    #expect(reencoded["parkCode"] == .string("acad"))
    #expect(reencoded["visitorcenters"] != nil)
  }

  @Test("A recorded amenity park entry re-encodes as the provider's flat object")
  func aRecordedAmenityParkEntryReEncodesAsTheProvidersFlatObject() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<[AmenityParkPlaces]>.self, from: Fixture.amenityParkPlacesPageFirst.data())
    let entry = try #require(page.data.first?.first?.parks?.first)
    let encoded = try JSONDecoder().decode(
      [String: JSONValue].self, from: try JSONEncoder().encode(entry))
    #expect(encoded["park"] == nil)
    #expect(encoded["designation"] == .string("National Park"))
    #expect(encoded["fullName"] == .string("Acadia National Park"))
    #expect(encoded["name"] == .string("Acadia"))
    #expect(encoded["parkCode"] == .string("acad"))
    #expect(encoded["states"] == .string("ME"))
    #expect(encoded["url"] == .string("http://www.nps.gov/acad/"))
    #expect(
      encoded["places"]
        == .array([
          .object([
            "id": .string("73CD84BA-F5B5-491E-A3B4-B5B6743668AC"),
            "title": .string("Jordan Pond House"),
            "url": .string("https://www.nps.gov/places/jordan-pond-house.htm"),
          ]),
          .object([
            "id": .string("EE4C8973-5FB0-47F0-8803-8A9A36870EF8"),
            "title": .string("Moore Auditorium"),
            "url": .string("https://www.nps.gov/places/acad_moore-auditorium.htm"),
          ]),
        ]))
    #expect(
      Set(encoded.keys) == [
        "designation", "fullName", "name", "parkCode", "places", "states", "url",
      ])
  }

  @Test("Quick facts and related organizations decode as sent")
  func quickFactsAndRelatedOrganizationsDecodeAsSent() throws {
    let fact = try JSONDecoder().decode(
      NPSQuickFact.self, from: Data(#"{"id":"F1","name":"Significance","value":""}"#.utf8))
    #expect(fact.id == "F1")
    #expect(fact.name == "Significance")
    #expect(fact.value == "")
    let organization = try JSONDecoder().decode(
      NPSRelatedOrganization.self, from: Data(#"{"id":"O1","name":null,"url":"u"}"#.utf8))
    #expect(organization.id == "O1")
    #expect(organization.name == nil)
    #expect(organization.url == "u")
    let empty = try JSONDecoder().decode(NPSQuickFact.self, from: Data("{}".utf8))
    #expect(empty.id == nil)
    #expect(empty.name == nil)
    #expect(empty.value == nil)
  }

  /// A minimal JSON tree used to inspect encoded output without depending on key order.
  private enum JSONValue: Decodable, Equatable {
    case array([JSONValue])
    case bool(Bool)
    case null
    case number(Double)
    case object([String: JSONValue])
    case string(String)

    init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()
      if container.decodeNil() {
        self = .null
      } else if let bool = try? container.decode(Bool.self) {
        self = .bool(bool)
      } else if let number = try? container.decode(Double.self) {
        self = .number(number)
      } else if let string = try? container.decode(String.self) {
        self = .string(string)
      } else if let array = try? container.decode([JSONValue].self) {
        self = .array(array)
      } else {
        self = .object(try container.decode([String: JSONValue].self))
      }
    }
  }
}
