import Foundation

/// Original public IRMA response bytes, recorded September 27, 2026.
package enum IRMAFixture: String, CaseIterable, Sendable {
  /// Original Landmark landmark-code.json response.
  case landmarkAppleton = "Landmarks/landmark-code.json"
  /// Original Landmark site-appleton.json response.
  case landmarkAppletonCounties = "Landmarks/site-appleton.json"
  /// Original Landmark county-all.json response.
  case landmarkCountyAll = "Landmarks/county-all.json"
  /// Original Landmark county-me.json response.
  case landmarkCountyMaine = "Landmarks/county-me.json"
  /// Original Landmark county-wy.json response.
  case landmarkCountyWyoming = "Landmarks/county-wy.json"
  /// Original Landmark landmark-unknown.json response.
  case landmarkEmpty = "Landmarks/landmark-unknown.json"
  /// Original Landmark state-unknown.json response.
  case landmarkHTTPFailure = "Landmarks/state-unknown.json"
  /// Original Landmark landmarks-me.json response.
  case landmarkMaine = "Landmarks/landmarks-me.json"
  /// Original Landmark owners-unknown.json response.
  case landmarkOwnerEmpty = "Landmarks/owners-unknown.json"
  /// Original Landmark owners-big-hollow.json response.
  case landmarkOwnerMultiple = "Landmarks/owners-big-hollow.json"
  /// Original Landmark owners-appleton.json response.
  case landmarkOwners = "Landmarks/owners-appleton.json"
  /// Original Landmark landmarks-county.json response.
  case landmarkPerCounty = "Landmarks/landmarks-county.json"
  /// Original Landmark landmarks-county-missing.json response.
  case landmarkPerCountyEmpty = "Landmarks/landmarks-county-missing.json"
  /// Original Landmark site-unknown.json response.
  case landmarkSiteCountiesEmpty = "Landmarks/site-unknown.json"
  /// Original Landmark site-wy.json response.
  case landmarkSiteWyoming = "Landmarks/site-wy.json"
  /// Original Landmark statecounty-me.json response.
  case landmarkStateCounties = "Landmarks/statecounty-me.json"
  /// Original Landmark statecounty-unknown.json response.
  case landmarkStateCountiesEmpty = "Landmarks/statecounty-unknown.json"
  /// Original Landmark groups.json response.
  case landmarkStateIndex = "Landmarks/groups.json"
  /// Original Landmark state-me.json response.
  case landmarkStateMaine = "Landmarks/state-me.json"
  /// Original Landmark states.json response.
  case landmarkStates = "Landmarks/states.json"
  /// Original Landmark state-missing.json response.
  case landmarkStateUnknown = "Landmarks/state-missing.json"
  /// Original Landmark withcounty-appleton.json response.
  case landmarkWithCounty = "Landmarks/withcounty-appleton.json"
  /// Original Landmark withcounty-unknown.json response.
  case landmarkWithCountyEmpty = "Landmarks/withcounty-unknown.json"
  /// Original Landmark withcounty-county.json response.
  case landmarkWithCountyFiltered = "Landmarks/withcounty-county.json"
  /// Original Landmark landmarks-wy.json response.
  case landmarkWyoming = "Landmarks/landmarks-wy.json"
  /// Recorded Species acad-checklist.json response.
  case speciesAcadiaChecklist = "Species/acad-checklist.json"
  /// Recorded Species acad-details.json response.
  case speciesAcadiaDetails = "Species/acad-details.json"
  /// Recorded Species acad-full.json response.
  case speciesAcadiaFull = "Species/acad-full.json"
  /// Original category XML, despite the format=json query.
  case speciesCategoryOptions = "Species/category-options.xml"
  /// Recorded Species empty.json response.
  case speciesEmpty = "Species/empty.json"
  /// Fort Point full list with category segment omitted.
  case speciesFortPointAll = "Species/fopo-all.json"
  /// Fort Point full list with birds,mammals in supplied order.
  case speciesFortPointBirdsMammals = "Species/fopo-birds-mammals.json"
  /// Recorded Species http-failure.html response.
  case speciesHTTPFailure = "Species/http-failure.html"
  /// Recorded Species yell-checklist.json response.
  case speciesYellowstoneChecklist = "Species/yell-checklist.json"
  /// Recorded Species yell-details.json response.
  case speciesYellowstoneDetails = "Species/yell-details.json"
  /// Recorded Species yell-full.json response.
  case speciesYellowstoneFull = "Species/yell-full.json"
  /// Original taxonomy tsn-81838-profile response.
  case taxonomy81838ITIS = "Taxonomy/tsn-81838-profile.json"
  /// Original taxonomy taxoncode-81838-profile response.
  case taxonomy81838NPS = "Taxonomy/taxoncode-81838-profile.json"
  /// Original taxonomy tsn-81838-basic response.
  case taxonomyBasicITIS = "Taxonomy/tsn-81838-basic.json"
  /// Original taxonomy taxoncode-81838-basic response.
  case taxonomyBasicNPS = "Taxonomy/taxoncode-81838-basic.json"
  /// Original taxonomy categories response.
  case taxonomyCategories = "Taxonomy/categories.json"
  /// Original taxonomy category-bird response.
  case taxonomyCategoryBird = "Taxonomy/category-bird.json"
  /// Original taxonomy category-mammal response.
  case taxonomyCategoryMammal = "Taxonomy/category-mammal.json"
  /// Original taxonomy searchbycommonname-profile response.
  case taxonomyCommonProfiles = "Taxonomy/searchbycommonname-profile.json"
  /// Original taxonomy searchbycommonname-basic response.
  case taxonomyCommonSummaries = "Taxonomy/searchbycommonname-basic.json"
  /// Original taxonomy profile-derived response.
  case taxonomyDerived = "Taxonomy/profile-derived.json"
  /// Original taxonomy searchbycommonname-unknown response.
  case taxonomyEmpty = "Taxonomy/searchbycommonname-unknown.json"
  /// Original taxonomy searchbycommonname-filtered-profile response.
  case taxonomyFilteredProfiles = "Taxonomy/searchbycommonname-filtered-profile.json"
  /// Original taxonomy searchbycommonname-filtered-basic response.
  case taxonomyFilteredSummaries = "Taxonomy/searchbycommonname-filtered-basic.json"
  /// Original taxonomy taxon-unknown response.
  case taxonomyHTTPFailure = "Taxonomy/taxon-unknown.json"
  /// Original taxonomy irma-basic response.
  case taxonomyIRMABasic = "Taxonomy/irma-basic.json"
  /// Original taxonomy crosswalk-quercus-irma response.
  case taxonomyIRMAProfiles = "Taxonomy/crosswalk-quercus-irma.json"
  /// Original taxonomy options-category response.
  case taxonomyOptionsCategory = "Taxonomy/options-category.json"
  /// Original taxonomy options-codeType response.
  case taxonomyOptionsCodeType = "Taxonomy/options-codeType.json"
  /// Original taxonomy options-detail response.
  case taxonomyOptionsDetail = "Taxonomy/options-detail.json"
  /// Original taxonomy options-paging response.
  case taxonomyOptionsPaging = "Taxonomy/options-paging.json"
  /// Original taxonomy options-source response.
  case taxonomyOptionsSource = "Taxonomy/options-source.json"
  /// Original taxonomy rank-genus response.
  case taxonomyRankGenus = "Taxonomy/rank-genus.json"
  /// Original taxonomy rank-species response.
  case taxonomyRankSpecies = "Taxonomy/rank-species.json"
  /// Original taxonomy ranks response.
  case taxonomyRanks = "Taxonomy/ranks.json"
  /// Original taxonomy searchbyscientificname-profile response.
  case taxonomyScientificProfiles = "Taxonomy/searchbyscientificname-profile.json"
  /// Original taxonomy searchbyscientificname-basic response.
  case taxonomyScientificSummaries = "Taxonomy/searchbyscientificname-basic.json"
  /// Original taxonomy source-categories response.
  case taxonomySourceCategories = "Taxonomy/source-categories.json"
  /// Original taxonomy source-categories-irma response.
  case taxonomySourceCategoriesIRMA = "Taxonomy/source-categories-irma.json"
  /// Original taxonomy source-irma response.
  case taxonomySourceIRMA = "Taxonomy/source-irma.json"
  /// Original taxonomy source-itis response.
  case taxonomySourceITIS = "Taxonomy/source-itis.json"
  /// Original taxonomy sources-profile response.
  case taxonomySourceProfiles = "Taxonomy/sources-profile.json"
  /// Original taxonomy source-ranks response.
  case taxonomySourceRanks = "Taxonomy/source-ranks.json"
  /// Original taxonomy source-ranks-irma response.
  case taxonomySourceRanksIRMA = "Taxonomy/source-ranks-irma.json"
  /// Original taxonomy sources-basic response.
  case taxonomySources = "Taxonomy/sources-basic.json"
  /// Original taxonomy tree-irma response.
  case taxonomyTreeIRMA = "Taxonomy/tree-irma.json"
  /// Original taxonomy tree-itis response.
  case taxonomyTreeITIS = "Taxonomy/tree-itis.json"
  /// Original taxonomy trees response.
  case taxonomyTrees = "Taxonomy/trees.json"
  /// Original Unit acad response.
  case unitAcadia = "Units/acad.json"
  /// Original Unit geography-acad response.
  case unitAcadiaGeography = "Units/geography-acad.json"
  /// Original Unit collections response.
  case unitCollections = "Units/collections.json"
  /// Original Unit county-hancock-full response.
  case unitCountyHancock = "Units/county-hancock-full.json"
  /// Original Unit county-park-full response.
  case unitCountyPark = "Units/county-park-full.json"
  /// Original Unit designation-np response.
  case unitDesignation = "Units/designation-np.json"
  /// Original Unit designations response.
  case unitDesignations = "Units/designations.json"
  /// Original Unit unknown response.
  case unitEmpty = "Units/unknown.json"
  /// Original Unit geography-unknown response.
  case unitGeographyEmpty = "Units/geography-unknown.json"
  /// Original Unit geo-envelope response.
  case unitGeographyEnvelope = "Units/geo-envelope.json"
  /// Original Unit geo-feature response.
  case unitGeographyFeature = "Units/geo-feature.json"
  /// Original Unit geo-gml response.
  case unitGeographyGML = "Units/geo-gml.json"
  /// Original Unit designation-unknown response.
  case unitHTTPFailure = "Units/designation-unknown.bin"
  /// Original Unit netn-linked response.
  case unitLinked = "Units/netn-linked.json"
  /// Original Unit netn-linked-functional response.
  case unitLinkedFunctional = "Units/netn-linked-functional.json"
  /// Original Unit netn-linked-logical response.
  case unitLinkedLogical = "Units/netn-linked-logical.json"
  /// Original Unit multiple response.
  case unitMultiple = "Units/multiple.json"
  /// Original Unit name response.
  case unitName = "Units/name.json"
  /// Original Unit nps response.
  case unitNational = "Units/nps.json"
  /// Original Unit points response.
  case unitPoints = "Units/points.json"
  /// Original Unit selector response.
  case unitSelector = "Units/selector.json"
  /// Original Unit semicolon response.
  case unitSemicolon = "Units/semicolon.json"
  /// Original Unit state-me response.
  case unitStateMaine = "Units/state-me.json"
  /// Original Unit states response.
  case unitStates = "Units/states.json"
  /// Original Unit state-wy response.
  case unitStateWyoming = "Units/state-wy.json"
  /// Original Unit subtype-op response.
  case unitSubtype = "Units/subtype-op.json"
  /// Original Unit subtypes response.
  case unitSubtypes = "Units/subtypes.json"
  /// Original Unit yell response.
  case unitYellowstone = "Units/yell.json"
  /// ACAD January and February 2025 from the visitation route.
  case visitationAcadiaMonths = "Visitation/acadia-months.json"
  /// Unknown unit ZZZZ, returning an empty array.
  case visitationEmpty = "Visitation/empty.json"
  /// Invalid months, preserving the original HTTP 500 HTML body.
  case visitationHTTPFailure = "Visitation/http-failure.html"
  /// National monthly records for 2025, retaining null unit identifiers.
  case visitationNationalMonths = "Visitation/national-months.json"
  /// November 2025 through February 2026, retaining only the two reported months.
  case visitationSparse = "Visitation/sparse.json"

  /// Reads the exact resource extension and unmodified response body.
  package func data() throws -> Data {
    guard
      let url = Bundle.module.url(
        forResource: rawValue, withExtension: nil, subdirectory: "Fixtures/IRMA")
    else { throw FixtureFailure.missing(name: rawValue) }
    return try Data(contentsOf: url)
  }
}
