import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSSpeciesModels
import Testing

@Suite("Species models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct SpeciesModelTests {
  @Test("Checklist and full list retain different provider membership")
  func listsRetainDifferentMembership() throws {
    let checklist = try JSONDecoder().decode(
      [SpeciesChecklistItem].self, from: IRMAFixture.speciesAcadiaChecklist.data())
    let full = try JSONDecoder().decode(
      [SpeciesItem].self, from: IRMAFixture.speciesAcadiaFull.data())
    #expect(checklist.count == 215)
    #expect(full.count == 364)
    #expect(checklist.first?.commonNames == "Cooper's Hawk")
    #expect(checklist.first?.scientificNameFormatted == "<em>Accipiter</em> <em>cooperii</em>")
    #expect(full.contains { $0.abundance == nil })
  }

  @Test("Mammal detail retains populated synonyms tags counts and missing fields")
  func mammalDetailRetainsPopulatedSynonymsTagsCountsAndMissingFields() throws {
    let rows = try JSONDecoder().decode(
      [SpeciesDetailItem].self, from: IRMAFixture.speciesYellowstoneDetails.data())
    #expect(rows.count == 78)
    #expect(rows.first?.npsTags == "Management Priority; Breeder")
    #expect(rows.first?.vouchers == 51)
    #expect(rows.first?.teStatus == "50")
    let synonym = try #require(rows.flatMap(\.synonyms).first)
    #expect(synonym.taxaCode == "115336")
    #expect(synonym.scientificName == "Felis rufus")
    #expect(rows.contains { $0.occurrence == nil })
    #expect(rows.contains { $0.observations == nil })
  }

  @Test("Omitted and comma categories retain original list membership")
  func omittedAndCommaCategoriesRetainOriginalListMembership() throws {
    let all = try JSONDecoder().decode(
      [SpeciesItem].self, from: IRMAFixture.speciesFortPointAll.data())
    let selected = try JSONDecoder().decode(
      [SpeciesItem].self, from: IRMAFixture.speciesFortPointBirdsMammals.data())
    #expect(all.count == 312)
    #expect(selected.count == 43)
    #expect(all.count > selected.count)
    #expect(selected.allSatisfy { $0.unitCode == "FOPO" })
  }

  @Test("Populated synonyms retain the same shape in every list")
  func populatedSynonymsRetainTheSameShapeInEveryList() throws {
    let checklist = try JSONDecoder().decode(
      [SpeciesChecklistItem].self, from: IRMAFixture.speciesYellowstoneChecklist.data())
    let full = try JSONDecoder().decode(
      [SpeciesItem].self, from: IRMAFixture.speciesYellowstoneFull.data())
    let detail = try JSONDecoder().decode(
      [SpeciesDetailItem].self, from: IRMAFixture.speciesYellowstoneDetails.data())
    let first = try #require(checklist.flatMap(\.synonyms).first)
    #expect(first.taxaCode == "115336")
    #expect(full.flatMap(\.synonyms).contains(first))
    #expect(detail.flatMap(\.synonyms).contains(first))
  }

  @Test("Unknown provider strings nulls and empty lists survive decoding")
  func unknownProviderStringsNullsAndEmptyListsSurviveDecoding() throws {
    var rows = try #require(
      JSONSerialization.jsonObject(with: IRMAFixture.speciesYellowstoneDetails.data())
        as? [[String: Any]])
    // Constructed edges use keys and values measured in all-category originals.
    rows[0]["CommonNames"] = NSNull()
    rows[0]["Family"] = NSNull()
    rows[0]["NativenessTags"] = "Cultivated"
    rows[0]["Occurrence"] = NSNull()
    rows[0]["Order"] = NSNull()
    rows[0]["OzoneSensitiveStatus"] = "O"
    rows[0]["Category"] = "Future category"
    rows[0]["RecordStatus"] = "Future status"
    let decoded = try JSONDecoder().decode(
      [SpeciesDetailItem].self, from: JSONSerialization.data(withJSONObject: rows))
    #expect(decoded[0].commonNames == nil && decoded[0].family == nil && decoded[0].order == nil)
    #expect(decoded[0].nativenessTags == "Cultivated")
    #expect(decoded[0].occurrence == nil)
    #expect(decoded[0].ozoneSensitiveStatus == "O")
    #expect(decoded[0].category == "Future category")
    #expect(decoded[0].recordStatus == "Future status")
    #expect(
      try JSONDecoder().decode([SpeciesItem].self, from: IRMAFixture.speciesEmpty.data()).isEmpty)
  }
}
