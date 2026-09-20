# Changelog

All notable changes are documented here. This project follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- NPSRelatedPark, the park summary NPS attaches to records from other groups, with `states` kept
  as the provider's comma-joined text.
- NPSImage.description and NPSImageCrop.ratio, the aspect ratio parsed as a number when the
  provider's text is numeric.
- NPSQuickFact, NPSRelatedOrganization, and NPSConstraintsInfo, decoded shapes for groups not yet
  queried.
- Places: Place, PlaceQuery, Endpoint.places(query:), NPSDataRequest.places(query:), and the lazy
  NPSDataClient.placePages(query:) and places(query:), with recorded places responses. The live
  endpoint rejects every sort value with HTTP 400, so PlaceQuery has no sort parameter. Place keeps
  the provider's four string flags, all three coordinate representations, and both image crop
  forms, which one places response sends together.
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

[Unreleased]: https://github.com/KalebCooper/swift-nps/compare/0.3.0...HEAD
[0.3.0]: https://github.com/KalebCooper/swift-nps/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/KalebCooper/swift-nps/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/KalebCooper/swift-nps/releases/tag/0.1.0
