import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Photo gallery asset models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PhotoGalleryAssetTests {
  @Test("Constructed photo gallery assets decode with nulls and unknown fields")
  func constructedPhotoGalleryAssetsDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded photo gallery assets send every key and no null values.
    let json = Data(
      #"""
      {"id":"A1","title":"Example Photo","permalinkUrl":null,"description":null,"altText":null,
      "fileInfo":{"url":null,"fileType":null,"widthPixels":null,"heightPixels":null,
      "fileSizeKb":null,"extra":1},"relatedParks":[{"parkCode":null,"extra":2}],"tags":null,
      "credit":null,"constraintsInfo":null,"copyright":null,"ordinal":null,
      "futureField":{"nested":true}}
      """#.utf8)
    let asset = try JSONDecoder().decode(PhotoGalleryAsset.self, from: json)
    #expect(asset.id == "A1")
    #expect(asset.title == "Example Photo")
    #expect(asset.altText == nil)
    #expect(asset.constraintsInfo == nil)
    #expect(asset.copyright == nil)
    #expect(asset.credit == nil)
    #expect(asset.description == nil)
    #expect(asset.fileInfo?.fileSizeKb == nil)
    #expect(asset.fileInfo?.fileType == nil)
    #expect(asset.fileInfo?.heightPixels == nil)
    #expect(asset.fileInfo?.url == nil)
    #expect(asset.fileInfo?.widthPixels == nil)
    #expect(asset.ordinal == nil)
    #expect(asset.permalinkUrl == nil)
    #expect(asset.relatedParks?.first?.parkCode == nil)
    #expect(asset.tags == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS photo gallery assets always carry an id and title.
    for body in [#"{"title":"Example Photo"}"#, #"{"id":"A1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(PhotoGalleryAsset.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Copyright text and file sizes are kept exactly as sent")
  func copyrightTextAndFileSizesAreKeptExactlyAsSent() throws {
    // Constructed, not recorded: a live scan carried this mis-encoded copyright sign, and file
    // sizes arrive as JSON integers with no documented unit.
    let json = Data(
      #"""
      {"id":"A1","title":"Example Photo","copyright":"Â© 2015 by Example",
      "fileInfo":{"fileSizeKb":5428193,"fileType":"image/tiff"}}
      """#.utf8)
    let asset = try JSONDecoder().decode(PhotoGalleryAsset.self, from: json)
    #expect(asset.copyright == "\u{C2}\u{A9} 2015 by Example")
    #expect(asset.fileInfo?.fileSizeKb == 5_428_193)
    #expect(asset.fileInfo?.fileType == "image/tiff")
  }

  @Test("Recorded photo gallery asset pages decode with their envelopes")
  func recordedPhotoGalleryAssetPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.photoGalleryAssetsPageFirst)
    #expect(first.total == "301")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["83ADD5BA-4D24-4DB9-BDC6-10506A4E86CA"])
    let last = try decode(.photoGalleryAssetsPageLast)
    #expect(last.total == "301")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["C432E255-D179-4812-9EB0-55EA4E17B07E"])
    let empty = try decode(.photoGalleryAssetsEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded file details, parks, ordinals, and constraints are kept as sent")
  func recordedFileDetailsParksOrdinalsAndConstraintsAreKeptAsSent() throws {
    let asset = try #require(try decode(.photoGalleryAssetsPageFirst).data.first)
    #expect(asset.title == "Continental soldiers firing muskets.")
    #expect(
      asset.altText
        == "Three people dressed as Continental soldiers fire muskets in a cloud of smoke towards "
        + "the woods.")
    #expect(
      asset.description
        == "Three living historians portraying Continental soldiers fire muskets at a historic "
        + "weapons demonstration.")
    #expect(
      asset.permalinkUrl
        == "https://www.nps.gov/media/photo/gallery-item.htm?pg=1"
        + "&id=83ADD5BA-4D24-4DB9-BDC6-10506A4E86CA&gid=1BBC09C6-5953-4AF1-8081-C4F1D68C6DA3")
    #expect(asset.ordinal == 1)
    #expect(asset.credit == "NPS photo")
    #expect(asset.tags == ["american revolution", "cowpens 243rd"])
    #expect(
      asset.copyright
        == "Permission must be secured from the individual copyright owners to reproduce any "
        + "copyrighted materials contained within this website. Digital assets without any "
        + "copyright restrictions are public domain.")
    #expect(
      asset.constraintsInfo
        == (try JSONDecoder().decode(
          NPSConstraintsInfo.self,
          from: Data(#"{"constraint":"Public domain","grantingRights":"Full"}"#.utf8))))
    let file = try #require(asset.fileInfo)
    #expect(
      file.url == "https://www.nps.gov/npgallery/GetAsset/83ADD5BA-4D24-4DB9-BDC6-10506A4E86CA")
    #expect(file.fileType == "image/jpeg")
    #expect(file.widthPixels == 6000)
    #expect(file.heightPixels == 4000)
    #expect(file.fileSizeKb == 7_712_262)
    let park = try #require(asset.relatedParks?.first)
    #expect(asset.relatedParks?.count == 1)
    #expect(park.designation == "National Battlefield")
    #expect(park.fullName == "Cowpens National Battlefield")
    #expect(park.name == "Cowpens")
    #expect(park.parkCode == "cowp")
    #expect(park.states == "SC")
    #expect(park.url == "https://www.nps.gov/cowp/index.htm")
  }

  @Test("Recorded search results keep repeated assets once per gallery in provider order")
  func recordedSearchResultsKeepRepeatedAssetsOncePerGalleryInProviderOrder() throws {
    let page = try decode(.photoGalleryAssetsSearch)
    #expect(page.total == "15")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(
      page.data.map(\.id) == [
        "F67A3393-6933-4650-9253-137B7A1887CF", "F67A3393-6933-4650-9253-137B7A1887CF",
      ])
    #expect(page.data.map(\.ordinal) == [3, 85])
    #expect(
      page.data.map(\.permalinkUrl) == [
        "https://www.nps.gov/media/photo/gallery-item.htm?pg=1"
          + "&id=F67A3393-6933-4650-9253-137B7A1887CF&gid=DF8E57F2-CD05-4163-B10C-47DF77EB1C2C",
        "https://www.nps.gov/media/photo/gallery-item.htm?pg=1"
          + "&id=F67A3393-6933-4650-9253-137B7A1887CF&gid=65356FE2-ABFD-42E5-BF92-E60467D6172A",
      ])
    let asset = try #require(page.data.first)
    #expect(asset.title == "1877 Bank Building")
    #expect(asset.credit == "National Archives & Records Administration")
    #expect(
      asset.tags == [
        "national register of historic places", "old west branch state bank",
        "west branch commercial historic district",
      ])
    #expect(asset.constraintsInfo?.constraint == "Public domain")
    #expect(asset.constraintsInfo?.grantingRights == "Full")
    #expect(asset.fileInfo?.fileSizeKb == 1_255_792)
    #expect(asset.relatedParks?.map(\.parkCode) == ["heho"])
  }

  @Test("A recorded gallery filter returns the gallery's assets in ordinal order")
  func aRecordedGalleryFilterReturnsTheGallerysAssetsInOrdinalOrder() throws {
    let page = try decode(.photoGalleryAssetsGallery)
    #expect(page.total == "2")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(
      page.data.map(\.id) == [
        "1FFC7F25-155D-4519-3E03-2F63E4D4DEF6", "1FFD9D01-155D-4519-3E22-7E6621EA92B3",
      ])
    #expect(page.data.map(\.title) == ["Chaplain Offers Prayer", "Colors"])
    #expect(page.data.map(\.ordinal) == [1, 2])
    #expect(page.data.map(\.credit) == ["", ""])
    #expect(page.data.map { $0.fileInfo?.widthPixels } == [800, 1200])
    #expect(page.data.map { $0.fileInfo?.heightPixels } == [1200, 800])
    #expect(page.data.map { $0.fileInfo?.fileSizeKb } == [287_785, 386_052])
    for asset in page.data {
      #expect(
        asset.permalinkUrl?.hasSuffix("&gid=1FFC7EF8-155D-4519-3ECC-B652E2E95E20") == true)
      #expect(asset.relatedParks?.map(\.parkCode) == ["wapa"])
      #expect(asset.relatedParks?.first?.states == "GU")
    }
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<PhotoGalleryAsset> {
    try JSONDecoder().decode(NPSCollection<PhotoGalleryAsset>.self, from: fixture.data())
  }
}
