import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Lesson plans", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct LessonPlanTests {
  @Test("The recorded search page decodes every lesson plan field as sent")
  func theRecordedSearchPageDecodesEveryLessonPlanFieldAsSent() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<LessonPlan>.self, from: Fixture.lessonPlansSearch.data())
    #expect(page.total == "4")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(page.data.count == 2)
    let menu = try #require(page.data.first)
    #expect(menu.id == "7D5B154C-2C39-476F-ABAF-A470ECC7CAFB")
    #expect(menu.url == "https://www.nps.gov/teachers/classrooms/bears-menu.htm")
    #expect(menu.title == "A Bear's Menu")
    #expect(menu.parks == ["yell"])
    #expect(
      menu.questionObjective
        == "The student will be able to: \u{2022} Describe the seasonal cycle of a bear\u{2019}s "
        + "life by examining its eating habits. \u{2022} Recognize the shape and size of an adult "
        + "grizzly bear and compare it to his/her own body size. \u{2022} Describe how to "
        + "distinguish black and grizzly bears.")
    #expect(menu.gradeLevel == "Middle School: Sixth Grade through Eighth Grade")
    let standards = try #require(menu.commonCore)
    #expect(standards.stateStandards == "")
    #expect(standards.additionalStandards == "NGSS: MS-LS2-1 and MS-LS2-4")
    #expect(standards.mathStandards == ["6.RP.3.d"])
    #expect(standards.elaStandards == ["6-8.RH.7", "6-8.RST.7"])
    #expect(menu.subjects == ["Literacy and Language Arts", "Math", "Science"])
    #expect(menu.duration == "90 Minutes")
  }

  @Test("A lesson plan keeps every related park code and empty standards as sent")
  func aLessonPlanKeepsEveryRelatedParkCodeAndEmptyStandardsAsSent() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<LessonPlan>.self, from: Fixture.lessonPlansSearch.data())
    let plan = try #require(page.data.last)
    #expect(plan.title == "Invent an Animal")
    #expect(plan.parks == ["grte", "yell"])
    let standards = try #require(plan.commonCore)
    #expect(standards.additionalStandards == "")
    #expect(standards.mathStandards == [])
    #expect(standards.elaStandards == [])
    #expect(standards.stateStandards?.hasPrefix("WY Grade 4 Science 1.5, 1.6, 1.9") == true)
    #expect(plan.subjects == ["Science"])
    #expect(plan.duration == "60 Minutes")
  }

  @Test("The recorded pages decode in descending title order")
  func theRecordedPagesDecodeInDescendingTitleOrder() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<LessonPlan>.self, from: Fixture.lessonPlansPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<LessonPlan>.self, from: Fixture.lessonPlansPageLast.data())
    #expect(first.total == "2")
    #expect(first.start == "0")
    #expect(last.start == "1")
    #expect(first.data.map(\.title) == ["Climate Change: Past, Present, and Future"])
    #expect(last.data.map(\.title) == ["Climate Change & Bird Range"])
    #expect(last.data.first?.id == "A1FFD964-0752-4245-8CF1-C19BF1FA5BB9")
    #expect(last.data.first?.gradeLevel == "High School: Ninth Grade through Twelfth Grade")
    for plan in first.data + last.data {
      #expect(plan.parks == ["tusk"])
    }
  }

  @Test("The recorded empty page decodes with no lesson plans")
  func theRecordedEmptyPageDecodesWithNoLessonPlans() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<LessonPlan>.self, from: Fixture.lessonPlansEmpty.data())
    #expect(page.total == "0")
    #expect(page.data.isEmpty)
  }

  @Test("A lesson plan with only identity and title decodes every other field as nil")
  func aLessonPlanWithOnlyIdentityAndTitleDecodesEveryOtherFieldAsNil() throws {
    let json = #"{"id":"A1","title":"Tracks","commonCore":{},"subject":null}"#
    let plan = try JSONDecoder().decode(LessonPlan.self, from: Data(json.utf8))
    #expect(plan.id == "A1")
    #expect(plan.title == "Tracks")
    #expect(plan.duration == nil)
    #expect(plan.gradeLevel == nil)
    #expect(plan.parks == nil)
    #expect(plan.questionObjective == nil)
    #expect(plan.subjects == nil)
    #expect(plan.url == nil)
    let standards = try #require(plan.commonCore)
    #expect(standards.additionalStandards == nil)
    #expect(standards.elaStandards == nil)
    #expect(standards.mathStandards == nil)
    #expect(standards.stateStandards == nil)
  }

  @Test("Encoding a lesson plan writes subjects under the provider's subject key")
  func encodingALessonPlanWritesSubjectsUnderTheProvidersSubjectKey() throws {
    let json = #"{"id":"A1","subject":["Math"],"title":"Tracks"}"#
    let plan = try JSONDecoder().decode(LessonPlan.self, from: Data(json.utf8))
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    #expect(String(decoding: try encoder.encode(plan), as: UTF8.self) == json)
  }
}
