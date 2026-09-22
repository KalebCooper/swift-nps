import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Topic parks", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TopicParksTests {
  @Test("The recorded search page decodes every topic and park field as sent")
  func theRecordedSearchPageDecodesEveryTopicAndParkFieldAsSent() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<TopicParks>.self, from: Fixture.topicParksSearch.data())
    #expect(page.total == "1")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    let topic = try #require(page.data.first)
    #expect(page.data.count == 1)
    #expect(topic.id == "7DA81DAB-5045-4953-9C20-36590AD9FA95")
    #expect(topic.name == "Women's History")
    let parks = try #require(topic.parks)
    #expect(parks.map(\.parkCode) == ["acad", "mamc"])
    let acadia = try #require(parks.first)
    #expect(acadia.designation == "National Park")
    #expect(acadia.fullName == "Acadia National Park")
    #expect(acadia.name == "Acadia")
    #expect(acadia.states == "ME")
    #expect(acadia.url == "https://www.nps.gov/acad/index.htm")
    let bethune = try #require(parks.last)
    #expect(bethune.designation == "National Historic Site\r\n")
    #expect(bethune.fullName == "Mary McLeod Bethune Council House National Historic Site")
    #expect(bethune.name == "Mary McLeod Bethune Council House")
    #expect(bethune.states == "DC")
    #expect(bethune.url == "https://www.nps.gov/mamc/index.htm")
  }

  @Test("The recorded pages narrow each topic to the requested park")
  func theRecordedPagesNarrowEachTopicToTheRequestedPark() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<TopicParks>.self, from: Fixture.topicParksPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<TopicParks>.self, from: Fixture.topicParksPageLast.data())
    #expect(first.total == "2")
    #expect(first.start == "0")
    #expect(last.start == "1")
    #expect(first.data.map(\.name) == ["Women's History"])
    #expect(last.data.map(\.name) == ["African American Heritage"])
    #expect(last.data.first?.id == "28AEAE85-9DDA-45B6-981B-1CFCDCC61E14")
    for topic in first.data + last.data {
      #expect(topic.parks?.map(\.parkCode) == ["mamc"])
    }
  }

  @Test("The recorded empty page decodes with no topics")
  func theRecordedEmptyPageDecodesWithNoTopics() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<TopicParks>.self, from: Fixture.topicParksEmpty.data())
    #expect(page.total == "0")
    #expect(page.data.isEmpty)
  }

  @Test(
    "A missing or null parks array decodes as nil",
    arguments: [#"{"id":"A1","name":"Arts"}"#, #"{"id":"A1","name":"Arts","parks":null}"#])
  func aMissingOrNullParksArrayDecodesAsNil(_ json: String) throws {
    let topic = try JSONDecoder().decode(TopicParks.self, from: Data(json.utf8))
    #expect(topic.id == "A1")
    #expect(topic.name == "Arts")
    #expect(topic.parks == nil)
  }
}
