import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Photo gallery models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PhotoGalleryTests {
  @Test("Constructed photo galleries decode with nulls and unknown fields")
  func constructedPhotoGalleriesDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded photo galleries send every key and no null values.
    let json = Data(
      #"""
      {"id":"G1","title":"Example Gallery","url":null,"description":null,
      "images":[{"url":null,"extra":1}],"relatedParks":[{"parkCode":null,"extra":2}],
      "tags":null,"assetCount":null,"constraintsInfo":{"constraint":null,"grantingRights":null,
      "extra":3},"copyright":null,"futureField":{"nested":true}}
      """#.utf8)
    let gallery = try JSONDecoder().decode(PhotoGallery.self, from: json)
    #expect(gallery.id == "G1")
    #expect(gallery.title == "Example Gallery")
    #expect(gallery.assetCount == nil)
    #expect(gallery.constraintsInfo?.constraint == nil)
    #expect(gallery.constraintsInfo?.grantingRights == nil)
    #expect(gallery.copyright == nil)
    #expect(gallery.description == nil)
    #expect(gallery.images?.first?.url == nil)
    #expect(gallery.relatedParks?.first?.parkCode == nil)
    #expect(gallery.tags == nil)
    #expect(gallery.url == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS photo galleries always carry an id and title.
    for body in [#"{"title":"Example Gallery"}"#, #"{"id":"G1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(PhotoGallery.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Missing constraints keys decode as nil and unknown constraint text is kept")
  func missingConstraintsKeysDecodeAsNilAndUnknownConstraintTextIsKept() throws {
    // Constructed, not recorded: every recorded constraints object sends both keys.
    let empty = try JSONDecoder().decode(NPSConstraintsInfo.self, from: Data("{}".utf8))
    #expect(empty.constraint == nil)
    #expect(empty.grantingRights == nil)
    let open = try JSONDecoder().decode(
      NPSConstraintsInfo.self,
      from: Data(#"{"constraint":"Future constraint","grantingRights":"Partial"}"#.utf8))
    #expect(open.constraint == "Future constraint")
    #expect(open.grantingRights == "Partial")
  }

  @Test("Recorded photo gallery pages decode with their envelopes")
  func recordedPhotoGalleryPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.photoGalleriesPageFirst)
    #expect(first.total == "13")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["195A5808-155D-451F-67A6-897B29577270"])
    let last = try decode(.photoGalleriesPageLast)
    #expect(last.total == "13")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["19A3CC98-155D-451F-67C2-E30B384719E7"])
    let empty = try decode(.photoGalleriesEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded preview images, parks, counts, and constraints are kept as sent")
  func recordedPreviewImagesParksCountsAndConstraintsAreKeptAsSent() throws {
    let gallery = try #require(try decode(.photoGalleriesPageFirst).data.first)
    #expect(gallery.title == "African-American History Month")
    #expect(
      gallery.url
        == "https://www.nps.gov/media/photo/gallery.htm?id=195A5808-155D-451F-67A6-897B29577270")
    #expect(
      gallery.description
        == "Theodore Roosevelt Birthplace has hosted many programs celebrating African-American "
        + "History Month.")
    #expect(gallery.assetCount == 19)
    #expect(gallery.tags == [])
    #expect(
      gallery.copyright
        == "Permission must be secured from the individual copyright owners to reproduce any "
        + "copyrighted materials contained within this website. Digital assets without any "
        + "copyright restrictions are public domain.")
    let image = try #require(gallery.images?.first)
    #expect(gallery.images?.count == 1)
    #expect(
      image.url == "https://www.nps.gov/npgallery/GetAsset/195A58B7-155D-451F-6753-8A479B337206")
    #expect(image.altText == "James and Nicola Rufus- Slavery Program")
    #expect(image.title == "James and Nicola Rufus- Slavery Program")
    #expect(image.description == "James and Nicola Rufus- Slavery Program")
    #expect(image.caption == nil)
    #expect(image.credit == nil)
    #expect(image.crops == nil)
    let park = try #require(gallery.relatedParks?.first)
    #expect(gallery.relatedParks?.count == 1)
    #expect(park.designation == "National Historic Site")
    #expect(park.fullName == "Theodore Roosevelt Birthplace National Historic Site")
    #expect(park.name == "Theodore Roosevelt Birthplace")
    #expect(park.parkCode == "thrb")
    #expect(park.states == "NY")
    #expect(park.url == "https://www.nps.gov/thrb/index.htm")
  }

  @Test("Recorded constraints decode as the provider's open text")
  func recordedConstraintsDecodeAsTheProvidersOpenText() throws {
    for fixture in [
      Fixture.photoGalleriesPageFirst, .photoGalleriesPageLast, .photoGalleriesSearch,
    ] {
      for gallery in try decode(fixture).data {
        #expect(
          gallery.constraintsInfo
            == (try JSONDecoder().decode(
              NPSConstraintsInfo.self,
              from: Data(#"{"constraint":"Public domain","grantingRights":"Unknown"}"#.utf8))))
        #expect(gallery.constraintsInfo?.constraint == "Public domain")
        #expect(gallery.constraintsInfo?.grantingRights == "Unknown")
      }
    }
  }

  @Test("Recorded search results keep tags, counts, and their provider order")
  func recordedSearchResultsKeepTagsCountsAndTheirProviderOrder() throws {
    let page = try decode(.photoGalleriesSearch)
    #expect(page.total == "3")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(
      page.data.map(\.id) == [
        "D2EB9B96-1DD8-B71B-0B4C-646D4E916D81", "2704673F-16D7-4E6F-90D0-98F3EAC93070",
      ])
    #expect(page.data.map(\.title) == ["Herbert Hoover National Historic Site", "Hoover Creek"])
    #expect(page.data.map(\.assetCount) == [19, 27])
    let site = try #require(page.data.first)
    #expect(site.tags == [])
    #expect(site.images?.first?.title == "Visitor Center Sign")
    #expect(site.images?.first?.description == "NPS/Denise Collar")
    let creek = try #require(page.data.last)
    #expect(creek.tags == ["stream", "hoover creek", "wapsinonoc river"])
    #expect(
      creek.images?.first?.altText
        == "A shallow creek meanders through a snow covered park landscape.")
    #expect(creek.relatedParks?.map(\.parkCode) == ["heho"])
    #expect(creek.relatedParks?.first?.states == "IA")
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<PhotoGallery> {
    try JSONDecoder().decode(NPSCollection<PhotoGallery>.self, from: fixture.data())
  }
}
