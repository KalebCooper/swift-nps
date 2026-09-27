import SwiftNPSDataTestSupport
import SwiftNPSSpeciesModels
import Testing

@Suite("Species queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct SpeciesQueryTests {
  @Test("Category omission uses the measured trailing slash")
  func categoryOmissionUsesTheMeasuredTrailingSlash() throws {
    let query = try SpeciesQuery(unitCode: "ACAD")
    #expect(SpeciesEndpoint.species(query: query).path == "/fulllist/ACAD/?format=json")
    #expect(SpeciesEndpoint.speciesChecklist(query: query).path == "/checklist/ACAD/?format=json")
    #expect(SpeciesEndpoint.speciesDetails(query: query).path == "/detaillist/ACAD/?format=json")
  }
  @Test("Category order spelling duplicates and escaped text are exact")
  func categoryOrderSpellingDuplicatesAndEscapedTextAreExact() throws {
    let query = try SpeciesQuery(categories: ["Birds", "mammals", "Birds"], unitCode: "A&B+é")
    #expect(
      SpeciesEndpoint.species(query: query).path
        == "/fulllist/A%26B%2B%C3%A9/Birds,mammals,Birds?format=json")
  }
  @Test("An empty supplied category list is rejected")
  func emptySuppliedCategoryListIsRejected() {
    #expect(throws: SpeciesQuery.ValidationError.self) {
      try SpeciesQuery(categories: [], unitCode: "ACAD")
    }
  }
  @Test(
    "Unsafe path components fail locally",
    arguments: ["", " ACAD", "ACAD\u{00A0}", "ACAD\n", "A/B", "A\\B", "..", "%2e%2e", "A,B"])
  func unsafePathComponentsFailLocally(_ value: String) {
    #expect(throws: SpeciesQuery.ValidationError.self) { try SpeciesQuery(unitCode: value) }
    #expect(throws: SpeciesQuery.ValidationError.self) {
      try SpeciesQuery(categories: [value], unitCode: "ACAD")
    }
  }

}
