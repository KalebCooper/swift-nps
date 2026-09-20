/// A reusable, typed NPS Data API operation that performs no I/O at construction.
///
/// Inspect ``resolution`` in a custom executor, or pass this value to `NPSDataClient.value(for:)`,
/// `pages(for:)`, or `items(for:)`. Constrained extensions can add application vocabulary without
/// erasing the response type.
///
/// ```swift
/// let request = NPSDataRequest.parks(parkCode: try ParkCode("acad"))
/// ```
public struct NPSDataRequest<Response>: Hashable, Sendable {
  /// The transport-independent operation required to obtain the response.
  public enum Resolution: Hashable, Sendable {
    /// Send a collection query; a paginating executor derives each following page from its response.
    case collection(NPSCollectionResolution<Response>)
    /// Send one endpoint and decode the response body as `Response`.
    case endpoint(Endpoint<Response>)
  }

  /// The operation a custom executor interprets.
  public let resolution: Resolution

  /// Creates a request for one endpoint, including a consumer-defined response.
  /// - Parameter endpoint: The endpoint whose body decodes directly as `Response`.
  public init(endpoint: Endpoint<Response>) {
    self.resolution = .endpoint(endpoint)
  }

  private init(resolution: Resolution) {
    self.resolution = resolution
  }
}

extension NPSDataRequest where Response == NPSCollection<ParkAlert> {
  /// Describes an alerts query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``ParkAlert``.
  public static func alerts(query: AlertQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<Amenity> {
  /// Describes an amenities query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``Amenity``.
  public static func amenities(query: AmenityQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<[AmenityParkPlaces]> {
  /// Describes an amenity park places query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   per-amenity groups of ``AmenityParkPlaces``.
  public static func amenityParkPlaces(query: AmenityParkPlacesQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<[AmenityParkVisitorCenters]> {
  /// Describes an amenity park visitor centers query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   per-amenity groups of ``AmenityParkVisitorCenters``.
  public static func amenityParkVisitorCenters(query: AmenityParkVisitorCentersQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<Campground> {
  /// Describes a campgrounds query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``Campground``.
  public static func campgrounds(query: CampgroundQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<Park> {
  /// Describes a lookup for one park code while retaining the provider envelope.
  /// - Parameter parkCode: A validated single park code.
  /// - Returns: A reusable request for ``NPSCollection`` of ``Park``.
  public static func parks(parkCode: ParkCode) -> Self {
    Self(endpoint: .parks(parkCode: parkCode))
  }

  /// Describes a parks query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of ``Park``.
  public static func parks(query: ParkQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<Place> {
  /// Describes a places query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``Place``.
  public static func places(query: PlaceQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<ThingToDo> {
  /// Describes a things to do query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``ThingToDo``.
  public static func thingsToDo(query: ThingToDoQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<Tour> {
  /// Describes a tours query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``Tour``.
  public static func tours(query: TourQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}

extension NPSDataRequest where Response == NPSCollection<VisitorCenter> {
  /// Describes a visitor centers query usable for one page or lazy iteration.
  ///
  /// A custom executor sends ``NPSCollectionResolution/endpoint`` and uses
  /// ``NPSCollectionResolution/next(after:)`` when more pages are desired. No request is sent
  /// during construction.
  /// - Parameter query: Validated query options.
  /// - Returns: An inspectable request whose individual response is ``NPSCollection`` of
  ///   ``VisitorCenter``.
  public static func visitorCenters(query: VisitorCenterQuery) -> Self {
    Self(resolution: .collection(NPSCollectionResolution(query)))
  }
}
