import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSTaxonomyModels
import Testing

@Suite("Taxonomy records", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TaxonModelTests {
  @Test("Basic records preserve formatted text and omitted external fields")
  func basicFields() throws {
    let nps = try JSONDecoder().decode(
      NPSTaxonSummary.self, from: IRMAFixture.taxonomyBasicNPS.data())
    #expect(nps.taxonCode == "81838" && nps.scientificName == "Pandion haliaetus")
    #expect(nps.kingdom == "Animalia" && nps.commonNames == "Osprey")
    #expect(nps.scientificNameFormatted == "<em>Pandion</em> <em>haliaetus</em>")
    let irma = try JSONDecoder().decode(
      NPSTaxonSummary.self, from: IRMAFixture.taxonomyIRMABasic.data())
    #expect(irma.taxonCode == "1313005" && irma.commonNames == "hybrid oak")
    #expect(irma.externalCode == nil && irma.externalCodeName == nil && irma.externalLink == nil)
    #expect(
      irma.scientificNameWithAuthority == nil && irma.scientificNameWithAuthorityFormatted == nil)
    let itis = try JSONDecoder().decode(
      NPSTaxonSummary.self, from: IRMAFixture.taxonomyBasicITIS.data())
    #expect(itis.commonNames == nil)
  }

  @Test("Metadata representations retain their own fields and provider order")
  func metadataRepresentations() throws {
    let decoder = JSONDecoder()
    let categories = try decoder.decode(
      [TaxonomicCategory].self, from: IRMAFixture.taxonomyCategories.data())
    #expect(categories.count == 17 && categories.prefix(2).map(\.code) == ["1", "2"])
    let bird = try decoder.decode(
      TaxonomicCategoryProfile.self, from: IRMAFixture.taxonomyCategoryBird.data())
    let mammal = try decoder.decode(
      TaxonomicCategoryProfile.self, from: IRMAFixture.taxonomyCategoryMammal.data())
    #expect(bird.pluralName == "Birds" && bird.externalCode == "510")
    #expect(mammal.code == "1" && mammal.pluralName == "Mammals")
    let ranks = try decoder.decode([TaxonomicRank].self, from: IRMAFixture.taxonomyRanks.data())
    #expect(ranks.count == 41 && ranks.first?.name == "_Unassigned")
    #expect(
      try decoder.decode(TaxonomicRank.self, from: IRMAFixture.taxonomyRankGenus.data()).code == "7"
    )
    let sources = try decoder.decode(
      [TaxonomicSource].self, from: IRMAFixture.taxonomySources.data())
    let profiles = try decoder.decode(
      [TaxonomicSourceProfile].self, from: IRMAFixture.taxonomySourceProfiles.data())
    #expect(sources.count == 10 && sources.first?.codeName == nil)
    #expect(profiles.count == 10 && profiles.first?.externalLink == nil)
    let irma = try decoder.decode(
      TaxonomicSourceProfile.self, from: IRMAFixture.taxonomySourceIRMA.data())
    #expect(irma.codeName == nil && irma.fullName == "IRMA Taxonomy Animals")
    let trees = try decoder.decode(
      [TaxonomicSourceTree].self, from: IRMAFixture.taxonomyTrees.data())
    #expect(trees.count == 10 && trees.first?.categories.count == 10)
    let tree = try decoder.decode(
      TaxonomicSourceTree.self, from: IRMAFixture.taxonomyTreeITIS.data())
    #expect(tree.categories.count == 16 && tree.ranks.count == 41)
    let irmaTree = try decoder.decode(
      TaxonomicSourceTree.self, from: IRMAFixture.taxonomyTreeIRMA.data())
    #expect(irmaTree.categories.count == 10)
    #expect(
      try decoder.decode(
        [TaxonomicCategory].self, from: IRMAFixture.taxonomySourceCategoriesIRMA.data())
        == irmaTree.categories)
    #expect(
      try decoder.decode([TaxonomicRank].self, from: IRMAFixture.taxonomySourceRanksIRMA.data())
        == irmaTree.ranks)
  }

  @Test("The same numeric text retains its explicit taxonomic namespace")
  func namespacesSelectDifferentTaxa() throws {
    let nps = try JSONDecoder().decode(
      NPSTaxonProfile.self, from: IRMAFixture.taxonomy81838NPS.data())
    let itis = try JSONDecoder().decode(
      NPSTaxonProfile.self, from: IRMAFixture.taxonomy81838ITIS.data())
    #expect(nps.taxonCode == "81838" && nps.scientificName == "Pandion haliaetus")
    #expect(itis.taxonCode == "719252" && itis.scientificName == "Bankia schrencki")
    #expect(nps.commonNames == ["Osprey"] && itis.commonNames == nil)
    #expect(nps.acceptedTaxa == nil && itis.acceptedTaxa?.first?.taxonCode == "719251")
    #expect(nps.synonyms?.first?.scientificName == "Falco haliaetus")
    #expect(nps.synonyms?.first?.resourceLink == nil)
    #expect(nps.orderedHierarchy[2].rank == "Infrakingdom   ")
    #expect(nps.classificationSource.detail?.code == "175590")
    #expect(nps.classificationSource.detail?.dataLink?.contains("itis.gov") == true)
    let irma = try JSONDecoder().decode(
      [NPSTaxonProfile].self, from: IRMAFixture.taxonomyIRMAProfiles.data())
    #expect(irma.first?.classificationSource.code == "IRMA_Plants")
    #expect(irma.first?.classificationSource.detail == nil)
    #expect(irma.first?.scientificNameWithAuthority == nil)
    let derived = try JSONDecoder().decode(
      NPSTaxonProfile.self, from: IRMAFixture.taxonomyDerived.data())
    #expect(derived.orderedHierarchy.count > itis.orderedHierarchy.count)
  }

  @Test("Synthetic crosswalks and future classifications remain representable")
  func syntheticCrosswalksAndOptionalArrays() throws {
    var object = try #require(
      JSONSerialization.jsonObject(with: IRMAFixture.taxonomy81838NPS.data()) as? [String: Any])
    object["Crosswalks"] = [
      ["TaxonCode": "future-01", "ScientificName": "Future name", "Rank": "Future rank"]
    ]
    object["Rank"] = "Future rank"
    object["LifecycleState"] = "Future status"
    object["AcceptedTaxa"] = NSNull()
    object["Synonyms"] = NSNull()
    object["CommonNames"] = NSNull()
    let value = try JSONDecoder().decode(
      NPSTaxonProfile.self, from: JSONSerialization.data(withJSONObject: object))
    #expect(value.crosswalks?.first?.taxonCode == "future-01")
    #expect(value.crosswalks?.first?.scientificName == "Future name")
    #expect(value.rank == "Future rank" && value.lifecycleState == "Future status")
    #expect(value.acceptedTaxa == nil && value.synonyms == nil && value.commonNames == nil)
    #expect(
      try JSONDecoder().decode(NPSTaxonProfile.self, from: JSONEncoder().encode(value)) == value)
  }
}
