# Changelog

All notable changes are documented here. This project follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Parking lots: ParkingLot, ParkingLot.Accessibility, ParkingLot.LiveStatus, ParkingLotQuery,
  Endpoint.parkingLots(query:), NPSDataRequest.parkingLots(query:), and the lazy
  NPSDataClient.parkingLots(query:) and parkingLotPages(query:), with recorded parking lot
  responses from `/parkinglots`. ParkingLotQuery sends sort fields without validation; the live
  endpoint sorts by `name` and `parkCode`. ParkingLot keeps its accessibility space counts as the
  provider's integers, correcting the misspelled `numberofAdaVanAccessbileSpaces` key, keeps live
  status fields as sent though they are stale and not guaranteed to be current, and uses the
  shared NPSContacts, NPSFee, and NPSOperatingHours.
- Park fees and passes: ParkFeesAndPasses, ParkFeesAndPasses.ContentOrderOrdinals,
  ParkFeesAndPasses.Fee, ParkFeesAndPasses.MultiSitePass, ParkFeesAndPasses.Pass,
  ParkFeesAndPasses.SeasonDate, ParkFeesAndPassesQuery, Endpoint.parkFeesAndPasses(query:),
  NPSDataRequest.parkFeesAndPasses(query:), and the lazy NPSDataClient.parkFeesAndPasses(query:)
  and parkFeesAndPassesPages(query:), with recorded fees and passes responses from `/feespasses`.
  ParkFeesAndPassesQuery sends sort fields without validation; the live endpoint sorts by
  `parkCode` and `fullName`. ParkFeesAndPasses keeps `cost` as the provider's text with no
  currency claimed, and SeasonDate keeps `day`, `holiday`, and `month` as sent, including the
  holiday-only form with a null day and month that a floating holiday such as Memorial Day cannot
  be derived from.
- Activity parks: ActivityParks, ActivityParksQuery, Endpoint.activityParks(query:),
  NPSDataRequest.activityParks(query:), and the lazy NPSDataClient.activityParks(query:) and
  activityParkPages(query:), with recorded activity parks responses from `/activities/parks`.
  ActivityParks lists each activity's parks as NPSRelatedPark values in a plain array, iterated as
  ordinary items with no flattening. ActivityParksQuery takes activity identifiers, park codes,
  text search, and sort fields sent without validation; the live endpoint sorts by `name`, ignores
  `stateCode`, and narrows each activity's `parks` to the requested park codes.
- Topic parks: TopicParks, TopicParksQuery, Endpoint.topicParks(query:),
  NPSDataRequest.topicParks(query:), and the lazy NPSDataClient.topicParks(query:) and
  topicParkPages(query:), with recorded topic parks responses from `/topics/parks`. TopicParks
  lists each topic's parks as NPSRelatedPark values in a plain array, iterated as ordinary items
  with no flattening. TopicParksQuery takes topic identifiers, park codes, text search, and sort
  fields sent without validation; the live endpoint sorts by `name`, ignores `stateCode`, and
  narrows each topic's `parks` to the requested park codes.
- Lesson plans: LessonPlan, LessonPlan.CommonCore, LessonPlanQuery, Endpoint.lessonPlans(query:),
  NPSDataRequest.lessonPlans(query:), and the lazy NPSDataClient.lessonPlans(query:) and
  lessonPlanPages(query:), with recorded lesson plans responses from `/lessonplans`.
  LessonPlanQuery takes lesson plan identifiers, park codes, state codes, text search, and sort
  fields sent without validation; the live endpoint sorts by `title`, ignores an unrecognized
  identifier rather than matching nothing, and does not narrow each plan's `parks` by the
  requested park codes.
- Activities: Activity, ActivityQuery, Endpoint.activities(query:),
  NPSDataRequest.activities(query:), and the lazy NPSDataClient.activities(query:) and
  activityPages(query:), with recorded activities responses from `/activities`. Activity keeps
  only an identifier and a name, with its own type rather than ActivityParks or NPSNamedItem, and
  no nested parks. ActivityQuery takes activity identifiers, park codes, text search, and sort
  fields sent without validation; the live endpoint sorts by `name`, ignores `stateCode`, and
  filters activities by park code with nothing to narrow.

## [0.5.0] - 2026-09-21

### Added

- Articles: Article, ArticleQuery, Endpoint.articles(query:), NPSDataRequest.articles(query:), and
  the lazy NPSDataClient.articlePages(query:) and articles(query:), with recorded articles
  responses. The live endpoint rejects a sort value with HTTP 400, so ArticleQuery has no sort
  parameter. Article keeps coordinates as JSON numbers or null and `latLong` as the provider's
  text.
- News releases: NewsRelease, NewsReleaseQuery, Endpoint.newsReleases(query:),
  NPSDataRequest.newsReleases(query:), and the lazy NPSDataClient.newsReleasePages(query:) and
  newsReleases(query:), with recorded news releases responses. NewsReleaseQuery sends sort fields
  without validation; the live endpoint sorts by `releaseDate` and `title`. NewsRelease keeps
  `releaseDate` and `lastIndexedDate` as the provider's text, which is not ISO 8601 and has no
  time zone, and uses the shared NPSImage, NPSRelatedPark, and NPSRelatedOrganization.
- People: Person, PersonQuery, Endpoint.people(query:), NPSDataRequest.people(query:), and the
  lazy NPSDataClient.people(query:) and personPages(query:), with recorded people responses. The
  live endpoint rejects a sort value with HTTP 400, so PersonQuery has no sort parameter. Person
  keeps `latitude`, `longitude`, and `latLong` as the provider's text, an empty string or decimal
  text, keeps `bodyText` as unmodified HTML, and uses the shared NPSImage, NPSQuickFact,
  NPSRelatedOrganization, and NPSRelatedPark.
- Park audio: ParkAudio, ParkAudio.Version, ParkAudioQuery, Endpoint.parkAudio(query:),
  NPSDataRequest.parkAudio(query:), and the lazy NPSDataClient.parkAudio(query:) and
  parkAudioPages(query:), with recorded park audio responses from `/multimedia/audio`.
  ParkAudioQuery sends sort fields without validation; the live endpoint sorts by `title`.
  ParkAudio keeps transcripts as plain text or HTML and each version's `fileSize` as the
  provider's number, for which NPS documents no unit, and uses the shared NPSImage and
  NPSRelatedPark.
- Park videos: ParkVideo, ParkVideo.CaptionFile, ParkVideo.Version, ParkVideoQuery,
  Endpoint.parkVideos(query:), NPSDataRequest.parkVideos(query:), and the lazy
  NPSDataClient.parkVideos(query:) and parkVideoPages(query:), with recorded park video responses
  from `/multimedia/videos`. ParkVideoQuery sends sort fields without validation; the live
  endpoint sorts by `title`. ParkVideo keeps its accessibility flags as the provider's Booleans,
  caption languages as open text, and each version's `fileSizeKb` as the provider's number or
  null, for which NPS documents no unit, and uses the shared NPSImage and NPSRelatedPark.
- Photo galleries: PhotoGallery, PhotoGalleryQuery, Endpoint.photoGalleries(query:),
  NPSDataRequest.photoGalleries(query:), and the lazy NPSDataClient.photoGalleries(query:) and
  photoGalleryPages(query:), with recorded photo gallery responses from `/multimedia/galleries`.
  PhotoGalleryQuery sends sort fields without validation; the live endpoint sorts by `title`.
  PhotoGallery keeps its preview images as the shared NPSImage, the provider's asset count, and
  the shared NPSRelatedPark.
- NPSConstraintsInfo, the rights and usage constraint text photo galleries and gallery assets
  carry, with `constraint` and `grantingRights` kept as open strings.
- Photo gallery assets: PhotoGalleryAsset, PhotoGalleryAssetQuery,
  Endpoint.photoGalleryAssets(query:), NPSDataRequest.photoGalleryAssets(query:), and the lazy
  NPSDataClient.photoGalleryAssets(query:) and photoGalleryAssetPages(query:), with recorded
  asset responses from `/multimedia/galleries/assets`. PhotoGalleryAssetQuery filters by gallery
  identifiers sent as `galleryId` and asset identifiers sent as `id`, and sends sort fields
  without validation; the live endpoint sorts by `title`. PhotoGalleryAsset keeps its file
  details as PhotoGalleryAsset.FileInfo, whose `fileSizeKb` is the provider's number, for which
  NPS documents no unit, and uses the shared NPSConstraintsInfo and NPSRelatedPark.
- Articles, news releases, people, park audio, park videos, photo galleries, and photo gallery
  assets in the iOS demo's group picker, each with search and paging. Photo gallery assets also
  takes gallery identifiers.

## [0.4.0] - 2026-09-20

### Added

- NPSRelatedPark, the park summary NPS attaches to records from other groups, with `states` kept
  as the provider's comma-joined text.
- NPSImage.description and NPSImageCrop.ratio, the aspect ratio parsed as a number when the
  provider's text is numeric.
- NPSQuickFact and NPSRelatedOrganization, the labeled facts and linked organizations a place
  publishes, kept as the provider sends them.
- Park boundaries: ParkBoundary, ParkBoundaryFeature, ParkBoundaryDetails, NPSGeometry,
  NPSCoordinateTree, Endpoint.parkBoundary(parkCode:), NPSDataRequest.parkBoundary(parkCode:), and
  NPSDataClient.parkBoundary(parkCode:), a single response decoding one park's GeoJSON boundary with
  recorded responses. NPSCoordinateTree keeps coordinates of any depth as sent, and
  NPSGeometry.lineString, polygon, and multiPolygon return typed arrays, or nil when the type or
  depth differs.
- Places: Place, PlaceQuery, Endpoint.places(query:), NPSDataRequest.places(query:), and the lazy
  NPSDataClient.placePages(query:) and places(query:), with recorded places responses. The live
  endpoint rejects every sort value with HTTP 400, so PlaceQuery has no sort parameter. Place keeps
  the provider's four string flags, all three coordinate representations, and both image crop
  forms, which one places response sends together.
- Road events: RoadEventFeed, RoadEventFeedInfo, RoadEventDataSource, RoadEventFeature,
  RoadEventDetails, RoadEventType, Endpoint.roadEvents(parkCode:type:),
  NPSDataRequest.roadEvents(parkCode:type:), and NPSDataClient.roadEvents(parkCode:type:), a single
  response decoding the WZDx 4.1 feed with recorded responses. RoadEventType sends the provider's
  spelling, such as `WorkZone`. RoadEventFeature.geometry is the shared NPSGeometry, whose
  `coordinates` is an `NPSCoordinateTree?` and whose positions are read through
  NPSGeometry.lineString, so a feature sent at another depth still decodes with its coordinates
  rather than failing the feed. RoadEventDetails keeps both provider
  identifiers, `Id` and `_id`, and incident and work types.
- Tours: Tour, Tour.Stop, TourQuery, Endpoint.tours(query:), NPSDataRequest.tours(query:), and
  the lazy NPSDataClient.tourPages(query:) and tours(query:), with recorded tours responses.
  TourQuery sorts by `relevanceScore`, the only field the live service accepts, and sends sort
  fields without validation. Tour keeps its singular `park`, string durations and duration unit,
  and each stop's string `ordinal`.
- Webcams: Webcam, WebcamQuery, Endpoint.webcams(query:), NPSDataRequest.webcams(query:), and the
  lazy NPSDataClient.webcamPages(query:) and webcams(query:), with recorded webcams responses. The
  live endpoint rejects every sort value with HTTP 400, so WebcamQuery has no sort parameter.
  Webcam keeps the provider's Boolean `isStreaming`, numeric or null coordinates, and open `status`
  text.
- Places, tours, webcams, road events, and park boundaries in the iOS demo's group picker. Road
  events and park boundaries are shown as one complete response rather than as pages.

### Changed

- NPSImageCrop.aspectRatio is `String?`: a JSON string is stored exactly as sent and a JSON number
  as its decimal text, because NPS sends both forms across and within responses.
- Replace NPSPassportStampImage with NPSImage; Campground.passportStampImages and
  VisitorCenter.passportStampImages are `[NPSImage]?`.
- Replace Park.Image with NPSImage; Park.images is `[NPSImage]?`.
- Replace ThingToDo.Image and ThingToDo.ImageCrop with NPSImage and NPSImageCrop;
  ThingToDo.images is `[NPSImage]?`.
- Replace ThingToDo.RelatedPark with NPSRelatedPark; ThingToDo.relatedParks is `[NPSRelatedPark]?`.
- AmenityParkPlaces.RelatedPark and AmenityParkVisitorCenters.RelatedPark hold the park summary as
  `park: NPSRelatedPark` beside their `places` or `visitorCenters` array instead of restating its
  fields.
- Rename AmenityParkPlaces.Place to AmenityParkPlaces.PlaceSummary, matching the sibling
  AmenityParkVisitorCenters.VisitorCenterSummary and leaving the top-level Place unshadowed.

## [0.3.0] - 2026-09-20

### Added

- NPSCollectionQuery, NPSQueryItem, and the generic Endpoint.collection factory shared by every
  offset-paginated collection; ParkQuery conforms and Endpoint.parks(query:) delegates to it.
- NPSCollectionResolution, the closure-free erasure of any collection query inside a request, and
  the generic NPSDataClient.pages(for:) and items(for:) that every collection convenience uses.
- Alerts: ParkAlert, AlertQuery, Endpoint.alerts(query:), NPSDataRequest.alerts(query:), and the
  lazy NPSDataClient.alertPages(query:) and alerts(query:), with recorded alerts responses.
- Amenities: Amenity, AmenityQuery, AmenityParkPlaces, AmenityParkPlacesQuery,
  AmenityParkVisitorCenters, AmenityParkVisitorCentersQuery, Endpoint and NPSDataRequest
  amenities(query:), amenityParkPlaces(query:), and amenityParkVisitorCenters(query:), the lazy
  NPSDataClient.amenityPages(query:), amenities(query:), amenityParkPlacePages(query:),
  amenityParkPlaces(query:), amenityParkVisitorCenterPages(query:), and
  amenityParkVisitorCenters(query:), and NPSFlattenedItemSequence, with recorded amenities
  responses. Park places and park visitor centers pages keep the provider's per-amenity groups;
  their item sequences flatten them.
- Campgrounds: Campground, CampgroundQuery, Endpoint.campgrounds(query:),
  NPSDataRequest.campgrounds(query:), and the lazy NPSDataClient.campgroundPages(query:) and
  campgrounds(query:), with recorded campgrounds responses.
- Things to do: ThingToDo, ThingToDoQuery, NPSIdentifier, Endpoint.thingsToDo(query:),
  NPSDataRequest.thingsToDo(query:), and the lazy NPSDataClient.thingToDoPages(query:) and
  thingsToDo(query:), with recorded things to do responses. NPSIdentifier validates identifier
  filters, which are sent as `id`.
- Visitor centers: VisitorCenter, VisitorCenterQuery, Endpoint.visitorCenters(query:),
  NPSDataRequest.visitorCenters(query:), and the lazy NPSDataClient.visitorCenterPages(query:) and
  visitorCenters(query:), with recorded visitor centers responses. Visitor center images and
  passport stamp images use the shared NPSImage, NPSImageCrop, and NPSPassportStampImage, also used
  by campgrounds.
- A group picker in the iOS demo to browse each collection.

### Changed

- Replace ParksResponse with the generic NPSCollection; parks pages are NPSCollection<Park>.
- Rename ParkPaginationError to NPSPaginationError.
- Replace the closed ParkSort enum with the open NPSSort value, and ParkSort.Order with
  NPSSort.Direction. Parks criteria are written as .ascending("fullName") or .descending("parkCode").
- Make ParkQuery.starting(at:) public as an NPSCollectionQuery requirement.
- Rename ParkRequest to NPSDataRequest; its Resolution.parks case becomes Resolution.collection
  carrying an NPSCollectionResolution.
- Replace ParkPageSequence with the generic NPSPageSequence; parks pages are NPSPageSequence<Park>.
- Replace ParkSequence with the generic NPSItemSequence; parks are NPSItemSequence<Park>.
- NPSDataError.pagination carries NPSPaginationError.
- Rename Park.Address to NPSAddress, shared by parks and visitor centers.
- Rename Park.Contacts to NPSContacts, shared by parks and visitor centers.
- Rename Park.EntranceFee to NPSFee, shared by park entrance fees and passes and campground fees.
- Rename Park.EmailAddress to NPSEmailAddress, shared by parks and visitor centers.
- Rename Park.Multimedia to NPSMultimedia, shared by parks and visitor centers.
- Rename Park.NamedItem to NPSNamedItem, shared by park and things to do activities and topics.
- Rename Park.OperatingHours to NPSOperatingHours, shared by parks and visitor centers.
- Rename Park.OperatingHoursException to NPSOperatingHoursException, shared by parks and visitor
  centers.
- Rename Park.PhoneNumber to NPSPhoneNumber, shared by parks and visitor centers.

## [0.2.0] - 2026-09-17

### Added

- Parks queries with multiple park and state codes, text search, sorting, and explicit pagination.
- Lazy parkPages and parks sequences backed by swifty-networking pagination, with reusable requests.
- Typed pagination failures for unusable metadata, contradictory counts, and nonprogressing offsets.
- Recorded multi-page and state-filtered search responses, query documentation, and a paginated demo.

### Changed

- Raise the swifty-networking dependency minimum to 1.1.0.

## [0.1.0] - 2026-09-13

### Added

- Parks lookup by one validated park code through NPSDataClient, ParkRequest, and Endpoint.
- Explicit API-key configuration using the X-Api-Key header, with typed service and transport errors.
- Codable park details and collection envelopes that preserve provider strings and optional values.
- Inspectable, Hashable requests and validated endpoints supporting consumer-defined responses.
- Recorded Acadia, Yellowstone, empty-result, and missing-key responses with offline behavior tests.
- Documentation catalogs, verification scripts, platform workflows, and an interactive iOS parks demo.

[Unreleased]: https://github.com/KalebCooper/swift-nps/compare/0.5.0...HEAD
[0.5.0]: https://github.com/KalebCooper/swift-nps/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/KalebCooper/swift-nps/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/KalebCooper/swift-nps/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/KalebCooper/swift-nps/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/KalebCooper/swift-nps/releases/tag/0.1.0
