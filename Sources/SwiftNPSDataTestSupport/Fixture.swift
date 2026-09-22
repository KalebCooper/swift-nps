import Foundation

/// A real NPS response body; each case names its exact request and recording date.
package enum Fixture: String, CaseIterable, Sendable {
  /// GET /api/v1/activities?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 22, 2026.
  case activitiesEmpty = "activities-empty"

  /// GET /api/v1/activities?id=AE42B46C-E4B7-4889-A122-08FE180371AE,
  /// 0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=0; HTTP 200.
  /// Recorded September 22, 2026.
  case activitiesPageFirst = "activities-page-first"

  /// GET /api/v1/activities?id=AE42B46C-E4B7-4889-A122-08FE180371AE,
  /// 0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=1; HTTP 200.
  /// Recorded September 22, 2026.
  case activitiesPageLast = "activities-page-last"

  /// GET /api/v1/activities?limit=2&parkCode=cwdw,drto&q=tours&sort=-name&start=0; HTTP 200.
  /// Recorded September 22, 2026.
  case activitiesSearch = "activities-search"

  /// GET /api/v1/activities/parks?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 22, 2026.
  case activityParksEmpty = "activities-parks-empty"

  /// GET /api/v1/activities/parks?id=AE42B46C-E4B7-4889-A122-08FE180371AE,
  /// 0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=0; HTTP 200.
  /// Recorded September 22, 2026.
  case activityParksPageFirst = "activities-parks-page-first"

  /// GET /api/v1/activities/parks?id=AE42B46C-E4B7-4889-A122-08FE180371AE,
  /// 0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=1; HTTP 200.
  /// Recorded September 22, 2026.
  case activityParksPageLast = "activities-parks-page-last"

  /// GET /api/v1/activities/parks?id=B33DC9B6-0B7D-4322-BAD7-A13A34C584A3,
  /// 0B685688-3405-4E2A-ABBA-E3069492EC50&limit=2&parkCode=cwdw,drto&q=tours&sort=-name&start=0;
  /// HTTP 200. Recorded September 22, 2026.
  case activityParksSearch = "activities-parks-search"

  /// GET /api/v1/alerts?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 17, 2026.
  case alertsEmpty = "alerts-empty"

  /// GET /api/v1/alerts?limit=1&parkCode=acad&start=0; HTTP 200. Recorded September 17, 2026.
  case alertsPageFirst = "alerts-page-first"

  /// GET /api/v1/alerts?limit=1&parkCode=acad&start=1; HTTP 200. Recorded September 17, 2026.
  case alertsPageLast = "alerts-page-last"

  /// GET /api/v1/alerts?limit=2&parkCode=acad,yell&start=0; HTTP 200. Recorded September 17, 2026.
  case alertsSearch = "alerts-search"

  /// GET /api/v1/amenities?limit=1&q=zzzzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 17, 2026.
  case amenitiesEmpty = "amenities-empty"

  /// GET /api/v1/amenities?limit=1&start=0; HTTP 200.
  /// Recorded September 17, 2026.
  case amenitiesPageFirst = "amenities-page-first"

  /// GET /api/v1/amenities?limit=1&start=1; HTTP 200.
  /// Recorded September 17, 2026.
  case amenitiesPageLast = "amenities-page-last"

  /// GET /api/v1/amenities?limit=2&q=restroom&start=0; HTTP 200.
  /// Recorded September 17, 2026.
  case amenitiesSearch = "amenities-search"

  /// GET /api/v1/amenities/parksplaces?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 17, 2026.
  case amenityParkPlacesEmpty = "amenities-parksplaces-empty"

  /// GET /api/v1/amenities/parksplaces?limit=1&parkCode=acad&start=0; HTTP 200.
  /// Recorded September 17, 2026.
  case amenityParkPlacesPageFirst = "amenities-parksplaces-page-first"

  /// GET /api/v1/amenities/parksplaces?limit=1&parkCode=acad&start=1; HTTP 200.
  /// Recorded September 17, 2026.
  case amenityParkPlacesPageLast = "amenities-parksplaces-page-last"

  /// GET /api/v1/amenities/parksvisitorcenters?limit=1&parkCode=zzzz&start=0; HTTP 200 with no
  /// matches. Recorded September 17, 2026.
  case amenityParkVisitorCentersEmpty = "amenities-parksvisitorcenters-empty"

  /// GET /api/v1/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=0; HTTP 200.
  /// Recorded September 17, 2026.
  case amenityParkVisitorCentersPageFirst = "amenities-parksvisitorcenters-page-first"

  /// GET /api/v1/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=1; HTTP 200.
  /// Recorded September 17, 2026.
  case amenityParkVisitorCentersPageLast = "amenities-parksvisitorcenters-page-last"

  /// GET /api/v1/parks?parkCode=acad&limit=1&start=0 without authentication; HTTP 403.
  /// Recorded September 13, 2026.
  case apiKeyMissing = "api-key-missing"

  /// GET /api/v1/articles?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 21, 2026.
  case articlesEmpty = "articles-empty"

  /// GET /api/v1/articles?limit=1&parkCode=arch&start=0; HTTP 200. Recorded September 21, 2026.
  case articlesPageFirst = "articles-page-first"

  /// GET /api/v1/articles?limit=1&parkCode=arch&start=1; HTTP 200. Recorded September 21, 2026.
  case articlesPageLast = "articles-page-last"

  /// GET /api/v1/articles?limit=2&parkCode=gumo&q=Salt&start=0&stateCode=TX; HTTP 200.
  /// Recorded September 21, 2026.
  case articlesSearch = "articles-search"

  /// GET /api/v1/campgrounds?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 17, 2026.
  case campgroundsEmpty = "campgrounds-empty"

  /// GET /api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=0; HTTP 200.
  /// Recorded September 17, 2026.
  case campgroundsPageFirst = "campgrounds-page-first"

  /// GET /api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=1; HTTP 200.
  /// Recorded September 17, 2026.
  case campgroundsPageLast = "campgrounds-page-last"

  /// GET /api/v1/campgrounds?limit=2&q=lake&sort=name&start=0&stateCode=WY; HTTP 200.
  /// Recorded September 17, 2026.
  case campgroundsSearch = "campgrounds-search"

  /// GET /api/v1/lessonplans?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 22, 2026.
  case lessonPlansEmpty = "lessonplans-empty"

  /// GET /api/v1/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=0; HTTP 200.
  /// Recorded September 22, 2026.
  case lessonPlansPageFirst = "lessonplans-page-first"

  /// GET /api/v1/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=1; HTTP 200.
  /// Recorded September 22, 2026.
  case lessonPlansPageLast = "lessonplans-page-last"

  /// GET /api/v1/lessonplans?limit=2&parkCode=grte,yell&q=bear&start=0&stateCode=WY; HTTP 200.
  /// Recorded September 22, 2026.
  case lessonPlansSearch = "lessonplans-search"

  /// GET /api/v1/newsreleases?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 21, 2026.
  case newsReleasesEmpty = "newsreleases-empty"

  /// GET /api/v1/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=0; HTTP 200.
  /// Recorded September 21, 2026.
  case newsReleasesPageFirst = "newsreleases-page-first"

  /// GET /api/v1/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=1; HTTP 200.
  /// Recorded September 21, 2026.
  case newsReleasesPageLast = "newsreleases-page-last"

  /// GET /api/v1/newsreleases?limit=2&parkCode=anac&q=advisory&sort=title&start=0&stateCode=DC;
  /// HTTP 200. Recorded September 21, 2026.
  case newsReleasesSearch = "newsreleases-search"

  /// GET /api/v1/multimedia/audio?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 21, 2026.
  case parkAudioEmpty = "audio-empty"

  /// GET /api/v1/multimedia/audio?limit=1&parkCode=choh&start=0; HTTP 200.
  /// Recorded September 21, 2026.
  case parkAudioPageFirst = "audio-page-first"

  /// GET /api/v1/multimedia/audio?limit=1&parkCode=choh&start=1; HTTP 200.
  /// Recorded September 21, 2026.
  case parkAudioPageLast = "audio-page-last"

  /// GET
  /// /api/v1/multimedia/audio?limit=2&parkCode=ever&q=alligator&sort=title&start=0&stateCode=FL;
  /// HTTP 200. Recorded September 21, 2026.
  case parkAudioSearch = "audio-search"

  /// GET /api/v1/mapdata/parkboundaries/drto; HTTP 200 with one MultiPolygon feature of two
  /// polygons. Recorded September 20, 2026.
  case parkBoundaryDryTortugas = "parkboundaries-drto"

  /// GET /api/v1/mapdata/parkboundaries/zzzz; HTTP 404 with an application/problem+json body.
  /// Recorded September 20, 2026.
  case parkBoundaryUnknown = "parkboundaries-unknown"

  /// GET /api/v1/mapdata/parkboundaries/yell; HTTP 200 with one Polygon feature.
  /// Recorded September 20, 2026.
  case parkBoundaryYellowstone = "parkboundaries-yell"

  /// GET /api/v1/feespasses?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 22, 2026.
  case parkFeesAndPassesEmpty = "feespasses-empty"

  /// GET /api/v1/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=0; HTTP 200.
  /// Recorded September 22, 2026.
  case parkFeesAndPassesPageFirst = "feespasses-page-first"

  /// GET /api/v1/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=1; HTTP 200.
  /// Recorded September 22, 2026.
  case parkFeesAndPassesPageLast = "feespasses-page-last"

  /// GET /api/v1/feespasses?limit=2&parkCode=deva,fova&q=annual&start=0&stateCode=CA,WA;
  /// HTTP 200. Recorded September 22, 2026.
  case parkFeesAndPassesSearch = "feespasses-search"

  /// GET /api/v1/parkinglots?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 21, 2026.
  case parkingLotsEmpty = "parkinglots-empty"

  /// GET /api/v1/parkinglots?limit=1&parkCode=chsc&sort=-name&start=0; HTTP 200.
  /// Recorded September 21, 2026.
  case parkingLotsPageFirst = "parkinglots-page-first"

  /// GET /api/v1/parkinglots?limit=1&parkCode=chsc&sort=-name&start=1; HTTP 200.
  /// Recorded September 21, 2026.
  case parkingLotsPageLast = "parkinglots-page-last"

  /// GET /api/v1/parkinglots?limit=2&parkCode=havo&q=overlook&sort=name&start=0&stateCode=HI;
  /// HTTP 200. Recorded September 21, 2026.
  case parkingLotsSearch = "parkinglots-search"

  /// GET /api/v1/parks?parkCode=acad&limit=1&start=0; HTTP 200.
  /// Recorded September 13, 2026.
  case parksAcadia = "parks-acad"

  /// GET /api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=2; HTTP 200.
  /// Recorded September 13, 2026.
  case parksBeyond = "parks-beyond"

  /// GET /api/v1/parks?parkCode=zzzz&limit=1&start=0; HTTP 200 with no matches.
  /// Recorded September 13, 2026.
  case parksEmpty = "parks-empty"

  /// GET /api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=0; HTTP 200.
  /// Recorded September 13, 2026.
  case parksPageFirst = "parks-page-first"

  /// GET /api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=1; HTTP 200.
  /// Recorded September 13, 2026.
  case parksPageLast = "parks-page-last"

  /// GET /api/v1/parks?limit=2&q=history&sort=-relevanceScore&start=0&stateCode=ME,MA; HTTP 200.
  /// Recorded September 13, 2026.
  case parksSearch = "parks-search"

  /// GET /api/v1/parks?parkCode=yell&limit=1&start=0; HTTP 200.
  /// Recorded September 13, 2026.
  case parksYellowstone = "parks-yell"

  /// GET /api/v1/multimedia/videos?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 21, 2026.
  case parkVideosEmpty = "videos-empty"

  /// GET /api/v1/multimedia/videos?limit=1&parkCode=crmo&start=0; HTTP 200.
  /// Recorded September 21, 2026.
  case parkVideosPageFirst = "videos-page-first"

  /// GET /api/v1/multimedia/videos?limit=1&parkCode=crmo&start=1; HTTP 200.
  /// Recorded September 21, 2026.
  case parkVideosPageLast = "videos-page-last"

  /// GET
  /// /api/v1/multimedia/videos?limit=2&parkCode=boaf&q=Boston&sort=title&start=0&stateCode=MA;
  /// HTTP 200. Recorded September 21, 2026.
  case parkVideosSearch = "videos-search"

  /// GET /api/v1/people?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 21, 2026.
  case peopleEmpty = "people-empty"

  /// GET /api/v1/people?limit=1&parkCode=yell&start=0; HTTP 200. Recorded September 21, 2026.
  case peoplePageFirst = "people-page-first"

  /// GET /api/v1/people?limit=1&parkCode=yell&start=1; HTTP 200. Recorded September 21, 2026.
  case peoplePageLast = "people-page-last"

  /// GET /api/v1/people?limit=2&parkCode=frla&q=Olmsted&start=0&stateCode=MA; HTTP 200.
  /// Recorded September 21, 2026.
  case peopleSearch = "people-search"

  /// GET /api/v1/multimedia/galleries?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 21, 2026.
  case photoGalleriesEmpty = "galleries-empty"

  /// GET /api/v1/multimedia/galleries?limit=1&parkCode=thrb&start=0; HTTP 200.
  /// Recorded September 21, 2026.
  case photoGalleriesPageFirst = "galleries-page-first"

  /// GET /api/v1/multimedia/galleries?limit=1&parkCode=thrb&start=1; HTTP 200.
  /// Recorded September 21, 2026.
  case photoGalleriesPageLast = "galleries-page-last"

  /// GET
  /// /api/v1/multimedia/galleries?limit=2&parkCode=heho&q=snow&sort=title&start=0&stateCode=IA;
  /// HTTP 200. Recorded September 21, 2026.
  case photoGalleriesSearch = "galleries-search"

  /// GET /api/v1/multimedia/galleries/assets?limit=1&parkCode=zzzz&start=0; HTTP 200 with no
  /// matches. Recorded September 21, 2026.
  case photoGalleryAssetsEmpty = "assets-empty"

  /// GET
  /// /api/v1/multimedia/galleries/assets?galleryId=1FFC7EF8-155D-4519-3ECC-B652E2E95E20&limit=2&start=0;
  /// HTTP 200, the gallery's complete asset set. Recorded September 21, 2026.
  case photoGalleryAssetsGallery = "assets-gallery"

  /// GET /api/v1/multimedia/galleries/assets?limit=1&parkCode=cowp&start=0; HTTP 200.
  /// Recorded September 21, 2026.
  case photoGalleryAssetsPageFirst = "assets-page-first"

  /// GET /api/v1/multimedia/galleries/assets?limit=1&parkCode=cowp&start=1; HTTP 200.
  /// Recorded September 21, 2026.
  case photoGalleryAssetsPageLast = "assets-page-last"

  /// GET
  /// /api/v1/multimedia/galleries/assets?limit=2&parkCode=heho&q=snow&sort=title&start=0&stateCode=IA;
  /// HTTP 200. Recorded September 21, 2026.
  case photoGalleryAssetsSearch = "assets-search"

  /// GET /api/v1/places?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 20, 2026.
  case placesEmpty = "places-empty"

  /// GET /api/v1/places?limit=1&parkCode=acad&start=0; HTTP 200. Recorded September 20, 2026.
  case placesPageFirst = "places-page-first"

  /// GET /api/v1/places?limit=1&parkCode=acad&start=1; HTTP 200. Recorded September 20, 2026.
  case placesPageLast = "places-page-last"

  /// GET /api/v1/places?limit=2&q=Redoubt&start=0&stateCode=FL; HTTP 200.
  /// Recorded September 20, 2026.
  case placesSearch = "places-search"

  /// GET /api/v1/roadevents?parkCode=dewa; HTTP 200 with eight features.
  /// Recorded September 20, 2026.
  case roadEventsDelawareWaterGap = "roadevents-dewa"

  /// GET /api/v1/roadevents?parkCode=acad; HTTP 200 with no features.
  /// Recorded September 20, 2026.
  case roadEventsEmpty = "roadevents-empty"

  /// GET /api/v1/roadevents?parkCode=yell&type=WorkZone; HTTP 200. Recorded September 20, 2026.
  case roadEventsType = "roadevents-type"

  /// GET /api/v1/roadevents?parkCode=yell; HTTP 200 with two features.
  /// Recorded September 20, 2026.
  case roadEventsYellowstone = "roadevents-yell"

  /// GET /api/v1/thingstodo?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 17, 2026.
  case thingsToDoEmpty = "thingstodo-empty"

  /// GET /api/v1/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=0; HTTP 200.
  /// Recorded September 17, 2026.
  case thingsToDoPageFirst = "thingstodo-page-first"

  /// GET /api/v1/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=1; HTTP 200.
  /// Recorded September 17, 2026.
  case thingsToDoPageLast = "thingstodo-page-last"

  /// GET /api/v1/thingstodo?limit=2&q=hike&sort=-relevanceScore&start=0&stateCode=ME; HTTP 200.
  /// Recorded September 17, 2026.
  case thingsToDoSearch = "thingstodo-search"

  /// GET /api/v1/topics/parks?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 22, 2026.
  case topicParksEmpty = "topics-parks-empty"

  /// GET /api/v1/topics/parks?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,
  /// 7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=0; HTTP 200.
  /// Recorded September 22, 2026.
  case topicParksPageFirst = "topics-parks-page-first"

  /// GET /api/v1/topics/parks?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,
  /// 7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=1; HTTP 200.
  /// Recorded September 22, 2026.
  case topicParksPageLast = "topics-parks-page-last"

  /// GET /api/v1/topics/parks?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,
  /// 7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=2&parkCode=acad,mamc&q=history&sort=-name&start=0;
  /// HTTP 200. Recorded September 22, 2026.
  case topicParksSearch = "topics-parks-search"

  /// GET /api/v1/tours?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 20, 2026.
  case toursEmpty = "tours-empty"

  /// GET /api/v1/tours?limit=1&parkCode=cavo&start=0; HTTP 200. Recorded September 20, 2026.
  case toursPageFirst = "tours-page-first"

  /// GET /api/v1/tours?limit=1&parkCode=cavo&start=1; HTTP 200. Recorded September 20, 2026.
  case toursPageLast = "tours-page-last"

  /// GET /api/v1/tours?id=7F1D5880-0FE9-5B95-492B8497DB1992A1&limit=2&parkCode=foma&q=Virtual
  /// &sort=-relevanceScore&start=0&stateCode=FL; HTTP 200. Recorded September 20, 2026.
  case toursSearch = "tours-search"

  /// GET /api/v1/visitorcenters?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 17, 2026.
  case visitorCentersEmpty = "visitorcenters-empty"

  /// GET /api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=0; HTTP 200.
  /// Recorded September 17, 2026.
  case visitorCentersPageFirst = "visitorcenters-page-first"

  /// GET /api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=1; HTTP 200.
  /// Recorded September 17, 2026.
  case visitorCentersPageLast = "visitorcenters-page-last"

  /// GET /api/v1/visitorcenters?limit=2&q=museum&sort=name&start=0&stateCode=ME,MA; HTTP 200.
  /// Recorded September 17, 2026.
  case visitorCentersSearch = "visitorcenters-search"

  /// GET /api/v1/webcams?limit=1&parkCode=zzzz&start=0; HTTP 200 with no matches.
  /// Recorded September 20, 2026.
  case webcamsEmpty = "webcams-empty"

  /// GET /api/v1/webcams?limit=1&parkCode=grte&start=0; HTTP 200. Recorded September 20, 2026.
  case webcamsPageFirst = "webcams-page-first"

  /// GET /api/v1/webcams?limit=1&parkCode=grte&start=1; HTTP 200. Recorded September 20, 2026.
  case webcamsPageLast = "webcams-page-last"

  /// GET /api/v1/webcams?id=9849DE2B-BC23-1110-33CED7C04E8AAF05&limit=2&parkCode=gumo&q=Capitan
  /// &start=0&stateCode=TX; HTTP 200. Recorded September 20, 2026.
  case webcamsSearch = "webcams-search"

  /// Reads the recorded JSON response; see Fixtures/README.md for lossless escaping.
  package func data() throws -> Data {
    guard
      let url = Bundle.module.url(
        forResource: rawValue, withExtension: "json", subdirectory: "Fixtures")
    else { throw FixtureFailure.missing(name: rawValue) }
    return try Data(contentsOf: url)
  }
}

/// Why a recorded response could not be read.
package enum FixtureFailure: Error, Hashable, Sendable {
  /// The named resource is absent from the bundle.
  case missing(name: String)
}
