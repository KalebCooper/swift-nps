import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Articles models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ArticleTests {
  @Test("Constructed articles decode with nulls and unknown fields")
  func constructedArticlesDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: recorded articles send every key and no null text.
    let json = Data(
      #"""
      {"id":"A1","title":"Example Article","url":null,"listingDescription":null,
      "listingImage":null,"relatedParks":[{"parkCode":null,"extra":1}],"tags":null,
      "latitude":null,"longitude":null,"latLong":null,"geometryPoiId":null,"credit":null,
      "futureField":{"nested":true}}
      """#.utf8)
    let article = try JSONDecoder().decode(Article.self, from: json)
    #expect(article.id == "A1")
    #expect(article.title == "Example Article")
    #expect(article.url == nil)
    #expect(article.credit == nil)
    #expect(article.geometryPoiId == nil)
    #expect(article.latitude == nil)
    #expect(article.latLong == nil)
    #expect(article.listingDescription == nil)
    #expect(article.listingImage == nil)
    #expect(article.longitude == nil)
    #expect(article.relatedParks?.first?.parkCode == nil)
    #expect(article.tags == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS articles always carry an id and title.
    for body in [#"{"title":"Example Article"}"#, #"{"id":"A1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(Article.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Article coordinates keep their JSON number type")
  func articleCoordinatesKeepTheirJSONNumberType() {
    // Constructed, not recorded: the provider sends numbers or null, never their text.
    for body in [
      #"{"id":"A1","title":"T","latitude":"31.9"}"#,
      #"{"id":"A1","title":"T","longitude":"-104.7"}"#,
    ] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(Article.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Recorded article pages decode with their envelopes")
  func recordedArticlePagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.articlesPageFirst)
    #expect(first.total == "117")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["DCEC38A7-B376-40DC-92E9-C46D92A272E9"])
    #expect(
      first.data.map(\.title) == [
        "Bipartisan Infrastructure Law and Burned Area Rehabilitation funds support restoration "
          + "of native plants in southeast Utah"
      ])
    let last = try decode(.articlesPageLast)
    #expect(last.total == "117")
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["B37992BF-7CC1-4350-8235-901C00C1A097"])
    #expect(last.data.map(\.title) == ["NPS Geodiversity Atlas\u{2014}Arches National Park, Utah"])
    let empty = try decode(.articlesEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded listing images, parks, and empty text are kept as sent")
  func recordedListingImagesParksAndEmptyTextAreKeptAsSent() throws {
    let article = try #require(try decode(.articlesPageFirst).data.first)
    #expect(
      article.url == "https://www.nps.gov/articles/000/bil-bar-se-utah-plant-restoration.htm")
    #expect(article.latitude == nil)
    #expect(article.longitude == nil)
    #expect(article.latLong == "")
    #expect(article.geometryPoiId == "")
    #expect(article.credit == "")
    #expect(article.tags?.count == 9)
    #expect(article.tags?.first == "wildland fire")
    #expect(article.tags?.last == "2024")
    let image = try #require(article.listingImage)
    #expect(
      image.url
        == "https://www.nps.gov/common/uploads/articles/images/nri/20240911/articles/"
        + "CFA57AD4-EDFF-99B6-E4238B5AA8444A14/CFA57AD4-EDFF-99B6-E4238B5AA8444A14.jpg")
    #expect(
      image.altText
        == "Three people in various parts of a field with rows of plants near an adobe structure.")
    #expect(image.caption == "")
    #expect(image.credit == "")
    #expect(image.crops == nil)
    #expect(image.description == "")
    #expect(image.title == "")
    let park = try #require(article.relatedParks?.first)
    #expect(article.relatedParks?.count == 1)
    #expect(park.designation == "National Park")
    #expect(park.fullName == "Arches National Park")
    #expect(park.name == "Arches")
    #expect(park.parkCode == "arch")
    #expect(park.states == "UT")
    #expect(park.url == "https://www.nps.gov/arch/index.htm")
  }

  @Test("Recorded search results keep numeric and null coordinates as sent")
  func recordedSearchResultsKeepNumericAndNullCoordinatesAsSent() throws {
    let page = try decode(.articlesSearch)
    #expect(page.total == "3")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(
      page.data.map(\.id) == [
        "54580218-6515-4AEB-9730-29E035DF23CF", "FA8F6462-6F58-4993-8A35-ABEE0EF32F26",
      ])
    let salt = try #require(page.data.first)
    #expect(salt.title == "El Paso Salt Wars")
    #expect(salt.latitude == nil)
    #expect(salt.longitude == nil)
    #expect(salt.latLong == "")
    #expect(
      salt.tags == ["El Paso", "Salt Wars", "United States", "mexico", "Texas rangers", "history"])
    let inventory = try #require(page.data.last)
    #expect(inventory.title == "Guadalupe Mountains National Park Reptile and Amphibian Inventory")
    #expect(inventory.latitude == 31.976943969726562)
    #expect(inventory.longitude == -104.75194549560547)
    #expect(inventory.latLong == "{lat:31.976943969726562, long:-104.75194549560547}")
    #expect(inventory.listingImage?.altText == "Desert box turtle")
    #expect(inventory.relatedParks?.map(\.parkCode) == ["gumo"])
    #expect(inventory.relatedParks?.map(\.states) == ["TX"])
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<Article> {
    try JSONDecoder().decode(NPSCollection<Article>.self, from: fixture.data())
  }
}
