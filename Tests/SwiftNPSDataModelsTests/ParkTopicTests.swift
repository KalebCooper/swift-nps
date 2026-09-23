import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Topics", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkTopicTests {
  @Test("The recorded search page decodes every topic field as sent")
  func theRecordedSearchPageDecodesEveryTopicFieldAsSent() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkTopic>.self, from: Fixture.topicsSearch.data())
    #expect(page.total == "1")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    let topic = try #require(page.data.first)
    #expect(page.data.count == 1)
    #expect(topic.id == "7DA81DAB-5045-4953-9C20-36590AD9FA95")
    #expect(topic.name == "Women's History")
  }

  @Test("The recorded pages advance through the requested identifiers")
  func theRecordedPagesAdvanceThroughTheRequestedIdentifiers() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<ParkTopic>.self, from: Fixture.topicsPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<ParkTopic>.self, from: Fixture.topicsPageLast.data())
    #expect(first.total == "2")
    #expect(first.start == "0")
    #expect(last.start == "1")
    #expect(first.data.map(\.name) == ["Women's History"])
    #expect(last.data.map(\.name) == ["African American Heritage"])
    #expect(last.data.first?.id == "28AEAE85-9DDA-45B6-981B-1CFCDCC61E14")
  }

  @Test("The recorded empty page decodes with no topics")
  func theRecordedEmptyPageDecodesWithNoTopics() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkTopic>.self, from: Fixture.topicsEmpty.data())
    #expect(page.total == "0")
    #expect(page.data.isEmpty)
  }

  @Test("A topic decodes its identifier and name as sent")
  func aTopicDecodesItsIdentifierAndNameAsSent() throws {
    let topic = try JSONDecoder().decode(
      ParkTopic.self, from: Data(#"{"id":"A1","name":"Wildlife"}"#.utf8))
    #expect(topic.id == "A1")
    #expect(topic.name == "Wildlife")
  }
}
