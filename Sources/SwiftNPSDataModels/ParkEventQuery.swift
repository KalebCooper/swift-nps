/// Validated filters for the NPS page-number events endpoint.
///
/// Defaults are explicitly false/1/10 for recurrence expansion, page number, and page size.
/// Empty lists omit their parameters; list order, case, and exact search text are retained.
/// Expanded responses support single-page execution only because NPS omits pagination metadata.
/// Subject filtering is omitted because tested subject values were ignored by the provider.
///
/// ```swift
/// let query = try ParkEventQuery(
///   dateEnd: ParkEventQuery.CalendarDate("2026-10-07"),
///   dateStart: ParkEventQuery.CalendarDate("2026-10-01"),
///   pageSize: 2, parkCodes: [ParkCode("yell")])
/// let endpoint = Endpoint.parkEvents(query: query)
/// ```
public struct ParkEventQuery: Hashable, Sendable {
  /// A canonical Gregorian calendar date with no time, locale, or timezone.
  public struct CalendarDate: Hashable, Sendable {
    /// The validated yyyy-MM-dd text, preserved exactly.
    public let rawValue: String

    /// Validates a real date in years 0001 through 9999.
    /// - Parameter value: Exactly ten ASCII characters in yyyy-MM-dd form.
    /// - Throws: ``ParkEventQuery/ValidationError/invalidDate`` for invalid syntax or date.
    public init(_ value: String) throws(ValidationError) {
      let bytes = Array(value.utf8)
      guard bytes.count == 10, bytes[4] == 45, bytes[7] == 45,
        bytes.enumerated().allSatisfy({ index, byte in
          index == 4 || index == 7 || (48...57).contains(byte)
        }),
        let year = Int(value.prefix(4)),
        let month = Int(value.dropFirst(5).prefix(2)),
        let day = Int(value.suffix(2)),
        year > 0, (1...12).contains(month)
      else { throw .invalidDate }
      let leap = year.isMultiple(of: 4) && (!year.isMultiple(of: 100) || year.isMultiple(of: 400))
      let days = [31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
      guard (1...days[month - 1]).contains(day) else { throw .invalidDate }
      rawValue = value
    }
  }

  /// Why event query values cannot be constructed.
  public enum ValidationError: Error, Hashable, Sendable {
    /// A date is not a real Gregorian date in canonical yyyy-MM-dd form.
    case invalidDate
    /// The page number must be positive.
    case invalidPageNumber
    /// The page size must be in 1...50.
    case invalidPageSize
    /// The ending date precedes the starting date.
    case reversedDateRange
  }

  /// The optional inclusive event-range ending date.
  public let dateEnd: CalendarDate?
  /// The optional inclusive event-range starting date.
  public let dateStart: CalendarDate?
  /// Open event types in caller order.
  public let eventTypes: [String]
  /// Whether NPS returns expanded occurrences as a single bare array.
  public let expandRecurring: Bool
  /// One exact event identifier, or nil to omit it.
  public let identifier: String?
  /// Open organization site codes; unknown codes may be ignored by NPS.
  public let organizations: [String]
  /// The positive one-based starting page.
  public let pageNumber: Int
  /// The requested page size, from 1 through 50.
  public let pageSize: Int
  /// Park codes in caller order; NPS state filters take precedence.
  public let parkCodes: [ParkCode]
  /// Open portal site codes; unknown codes may be ignored by NPS.
  public let portals: [String]
  /// Exact search text, including an explicitly empty string.
  public let searchText: String?
  /// State codes in caller order, taking precedence over park codes.
  public let stateCodes: [StateCode]
  /// Tags sent to the provider's tagsAll filter.
  public let tagsAll: [String]
  /// Tags sent to the provider's tagsNone filter.
  public let tagsNone: [String]
  /// Tags sent to tagsOne; mixed tags did not reliably behave as a union.
  public let tagsOne: [String]

  /// Creates a query without contacting NPS or normalizing caller values.
  /// - Parameters:
  ///   - dateEnd: The optional inclusive event-range ending date.
  ///   - dateStart: The optional inclusive event-range starting date.
  ///   - eventTypes: Open event types in caller order.
  ///   - expandRecurring: Whether NPS returns expanded occurrences as a single bare array.
  ///   - identifier: One exact event identifier, or nil to omit it.
  ///   - organizations: Open organization site codes; unknown codes may be ignored by NPS.
  ///   - pageNumber: The positive one-based starting page.
  ///   - pageSize: The requested page size, from 1 through 50.
  ///   - parkCodes: Park codes in caller order; NPS state filters take precedence.
  ///   - portals: Open portal site codes; unknown codes may be ignored by NPS.
  ///   - searchText: Exact search text, including an explicitly empty string.
  ///   - stateCodes: State codes in caller order, taking precedence over park codes.
  ///   - tagsAll: Tags sent to the provider's tagsAll filter.
  ///   - tagsNone: Tags sent to the provider's tagsNone filter.
  ///   - tagsOne: Tags sent to tagsOne; mixed tags did not reliably behave as a union.
  /// - Throws: ``ValidationError`` for invalid pagination or a reversed date range.
  public init(
    dateEnd: CalendarDate? = nil,
    dateStart: CalendarDate? = nil,
    eventTypes: [String] = [],
    expandRecurring: Bool = false,
    identifier: String? = nil,
    organizations: [String] = [],
    pageNumber: Int = 1,
    pageSize: Int = 10,
    parkCodes: [ParkCode] = [],
    portals: [String] = [],
    searchText: String? = nil,
    stateCodes: [StateCode] = [],
    tagsAll: [String] = [],
    tagsNone: [String] = [],
    tagsOne: [String] = []
  ) throws(ValidationError) {
    guard pageNumber > 0 else { throw .invalidPageNumber }
    guard (1...50).contains(pageSize) else { throw .invalidPageSize }
    if let dateEnd, let dateStart, dateEnd.rawValue < dateStart.rawValue {
      throw .reversedDateRange
    }
    self.dateEnd = dateEnd
    self.dateStart = dateStart
    self.eventTypes = eventTypes
    self.expandRecurring = expandRecurring
    self.identifier = identifier
    self.organizations = organizations
    self.pageNumber = pageNumber
    self.pageSize = pageSize
    self.parkCodes = parkCodes
    self.portals = portals
    self.searchText = searchText
    self.stateCodes = stateCodes
    self.tagsAll = tagsAll
    self.tagsNone = tagsNone
    self.tagsOne = tagsOne
  }

  private init(copy: Self, pageNumber: Int) {
    self.dateEnd = copy.dateEnd
    self.dateStart = copy.dateStart
    self.eventTypes = copy.eventTypes
    self.expandRecurring = copy.expandRecurring
    self.identifier = copy.identifier
    self.organizations = copy.organizations
    self.pageNumber = pageNumber
    self.pageSize = copy.pageSize
    self.parkCodes = copy.parkCodes
    self.portals = copy.portals
    self.searchText = copy.searchText
    self.stateCodes = copy.stateCodes
    self.tagsAll = copy.tagsAll
    self.tagsNone = copy.tagsNone
    self.tagsOne = copy.tagsOne
  }

  /// Parameters in deterministic wire-name order, omitting empty lists.
  public var queryItems: [NPSQueryItem] {
    var items: [NPSQueryItem] = []
    if let dateEnd { items.append(NPSQueryItem(name: "dateEnd", value: dateEnd.rawValue)) }
    if let dateStart { items.append(NPSQueryItem(name: "dateStart", value: dateStart.rawValue)) }
    if !eventTypes.isEmpty { items.append(NPSQueryItem(name: "eventType", values: eventTypes)) }
    items.append(NPSQueryItem(name: "expandRecurring", value: String(expandRecurring)))
    if let identifier { items.append(NPSQueryItem(name: "id", value: identifier)) }
    if !organizations.isEmpty {
      items.append(NPSQueryItem(name: "organization", values: organizations))
    }
    items.append(NPSQueryItem(name: "pageNumber", value: String(pageNumber)))
    items.append(NPSQueryItem(name: "pageSize", value: String(pageSize)))
    if !parkCodes.isEmpty {
      items.append(NPSQueryItem(name: "parkCode", values: parkCodes.map(\.rawValue)))
    }
    if !portals.isEmpty { items.append(NPSQueryItem(name: "portal", values: portals)) }
    if let searchText { items.append(NPSQueryItem(name: "q", value: searchText)) }
    if !stateCodes.isEmpty {
      items.append(NPSQueryItem(name: "stateCode", values: stateCodes.map(\.rawValue)))
    }
    if !tagsAll.isEmpty { items.append(NPSQueryItem(name: "tagsAll", values: tagsAll)) }
    if !tagsNone.isEmpty { items.append(NPSQueryItem(name: "tagsNone", values: tagsNone)) }
    if !tagsOne.isEmpty { items.append(NPSQueryItem(name: "tagsOne", values: tagsOne)) }
    return items.sorted { $0.name < $1.name }
  }

  /// Validates an ordinary page and describes its successor, preserving every filter.
  ///
  /// An empty page is terminal only at or beyond total. A short page before total is
  /// inconsistent. Totals may change between responses; no stable snapshot is promised.
  /// Custom executors must handle reported service errors before interpreting continuation.
  /// - Parameter response: The response to this query.
  /// - Returns: The next query, or nil when the returned range reaches the reported total.
  /// - Throws: ``NPSPaginationError`` for expansion, inconsistent metadata, or overflow.
  public func next(after response: ParkEventCollection) throws(NPSPaginationError) -> Self? {
    guard !expandRecurring, let page = response.page else { throw .eventExpansionUnavailable }
    let number = try Self.integer(page.pageNumber, field: "pagenumber")
    let size = try Self.integer(page.pageSize, field: "pagesize")
    let total = try Self.integer(page.total, field: "total")
    guard number > 0 else { throw .invalidMetadata(field: "pagenumber", value: page.pageNumber) }
    guard size > 0 else { throw .invalidMetadata(field: "pagesize", value: page.pageSize) }
    guard number == pageNumber else {
      throw .unexpectedPageNumber(actual: number, expected: pageNumber)
    }
    guard size == pageSize else { throw .unexpectedPageSize(actual: size, expected: pageSize) }
    let (start, overflow) = (number - 1).multipliedReportingOverflow(by: size)
    guard !overflow else { throw .offsetOverflow }
    guard page.data.count <= size else { throw .inconsistentPage }
    if page.data.isEmpty {
      guard start >= total else { throw .inconsistentPage }
      return nil
    }
    let (end, endOverflow) = start.addingReportingOverflow(page.data.count)
    guard !endOverflow else { throw .offsetOverflow }
    guard end <= total else { throw .inconsistentPage }
    if end == total { return nil }
    guard page.data.count == size else { throw .inconsistentPage }
    let (following, pageOverflow) = number.addingReportingOverflow(1)
    guard !pageOverflow else { throw .offsetOverflow }
    return Self(copy: self, pageNumber: following)
  }

  package func starting(at pageNumber: Int) -> Self {
    Self(copy: self, pageNumber: pageNumber)
  }

  private static func integer(_ value: String, field: String) throws(NPSPaginationError) -> Int {
    guard !value.isEmpty, value.utf8.allSatisfy({ (48...57).contains($0) }),
      let number = Int(value)
    else { throw .invalidMetadata(field: field, value: value) }
    return number
  }
}
