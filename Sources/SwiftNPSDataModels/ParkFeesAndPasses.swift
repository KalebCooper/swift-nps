#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// One park's entrance fees, annual passes, and fee guidance from the NPS fees and passes API.
///
/// The provider sends one record per park, identified by its required ``parkCode``. Other
/// documented fields are optional, preserving missing or null values without substituting empty
/// strings or arrays. Costs are provider text such as `"55.00"` and are not converted to numbers;
/// the provider does not state a currency. ``cashless`` is free text rather than a Boolean. The
/// four `is` flags arrive as JSON Booleans and keep that type. Unknown JSON fields are ignored by
/// Codable.
///
/// ```swift
/// let page = try JSONDecoder().decode(NPSCollection<ParkFeesAndPasses>.self, from: data)
/// for park in page.data {
///   print(park.parkCode, park.fees?.count ?? 0, park.passes?.count ?? 0)
/// }
/// ```
public struct ParkFeesAndPasses: Codable, Hashable, Sendable {
  /// The provider's display order for the fee sections of a park page, as JSON integers.
  ///
  /// ```swift
  /// if let order = park.contentOrderOrdinals {
  ///   print(order.entranceFee ?? 0, order.customFee ?? 0)
  /// }
  /// ```
  public struct ContentOrderOrdinals: Codable, Hashable, Sendable {
    /// The position of the custom fee section.
    public let customFee: Int?

    /// The position of the entrance fee section.
    public let entranceFee: Int?

    /// The position of the paid parking section.
    public let paidParking: Int?

    /// The position of the timed entry section.
    public let timedEntry: Int?
  }

  /// One entrance or timed-entry fee, with its season and purchase links kept as sent.
  ///
  /// ```swift
  /// for fee in park.fees ?? [] {
  ///   print(fee.entranceFeeType ?? "", fee.cost ?? "")
  /// }
  /// ```
  public struct Fee: Codable, Hashable, Sendable {
    /// The provider's cost text, such as `"30.00"`, not converted to a number.
    public let cost: String?

    /// The provider's description of the fee, including an empty string.
    public let description: String?

    /// The last day of the fee's season, or nil when unavailable.
    public let endDate: SeasonDate?

    /// The provider's fee type text, such as `"Entrance - Private Vehicle"`, kept as an open
    /// string.
    public let entranceFeeType: String?

    /// The provider's exceptions text, including an empty string.
    public let exceptions: String?

    /// The fee identifier, preserved without UUID parsing.
    public let id: String?

    /// The provider's information URL text, including an empty string.
    public let informationUrl: String?

    /// The provider's NPS.gov purchase URL text, including an empty string.
    public let npsGovPurchaseUrl: String?

    /// The provider's Pay.gov purchase URL text, including an empty string.
    public let payGovPurchaseUrl: String?

    /// The provider's description of accepted payment, including an empty string.
    public let paymentDescription: String?

    /// The provider's Recreation.gov purchase URL text, including an empty string.
    public let recGovPurchaseUrl: String?

    /// The first day of the fee's season, or nil when unavailable.
    public let startDate: SeasonDate?

    /// The provider's timed-entry location text, including an empty string.
    public let timedEntryLocation: String?

    /// The provider's short timed-entry description, including an empty string.
    public let timedEntryShortDescription: String?
  }

  /// A pass sold for entry to several parks, with the parks it covers.
  ///
  /// The provider's `image` key holds an array and decodes into ``images``. Every recorded
  /// multi-site pass sends that array empty, so the image shape is assumed to match ``NPSImage``
  /// rather than observed.
  ///
  /// ```swift
  /// for pass in park.relatedMultiSitePasses ?? [] {
  ///   print(pass.title ?? "", pass.relatedParks?.map(\.parkCode) ?? [])
  /// }
  /// ```
  public struct MultiSitePass: Codable, Hashable, Sendable {
    /// The provider's description of who the pass is for, including an empty string.
    public let audience: String?

    /// The provider's cost text, such as `"55.00"`, not converted to a number.
    public let cost: String?

    /// The provider's description of the pass, including an empty string.
    public let description: String?

    /// Images for the pass, decoded from the provider's `image` key, including an empty array.
    public let images: [NPSImage]?

    /// Parks the pass covers, in the order sent, including an empty array.
    public let relatedParks: [NPSRelatedPark]?

    /// The pass's display title.
    public let title: String?

    /// The provider's pass type text, such as `"Multi-Site Pass"`, kept as an open string.
    public let type: String?

    private enum CodingKeys: String, CodingKey {
      case audience
      case cost
      case description
      case images = "image"
      case relatedParks
      case title
      case type
    }
  }

  /// An annual pass sold for one park.
  ///
  /// The provider's `image` key holds an array and decodes into ``images``. Pass images send
  /// attribution, text, and URL fields but no crops or description.
  ///
  /// ```swift
  /// for pass in park.passes ?? [] {
  ///   print(pass.category ?? "", pass.cost ?? "")
  /// }
  /// ```
  public struct Pass: Codable, Hashable, Sendable {
    /// The provider's pass category text, such as `"Annual Entrance - Park"`, kept as an open
    /// string.
    public let category: String?

    /// The provider's cost text, such as `"55.00"`, not converted to a number.
    public let cost: String?

    /// The provider's description of the pass, including an empty string.
    public let description: String?

    /// The provider's exceptions text, including an empty string.
    public let exceptions: String?

    /// The pass identifier, preserved without UUID parsing.
    public let id: String?

    /// Images for the pass, decoded from the provider's `image` key, including an empty array.
    public let images: [NPSImage]?

    /// The provider's information URL text, including an empty string.
    public let informationUrl: String?

    /// The provider's NPS.gov purchase URL text, including an empty string.
    public let npsGovPurchaseUrl: String?

    /// The provider's Pay.gov purchase URL text, including an empty string.
    public let payGovPurchaseUrl: String?

    /// The provider's description of accepted payment, including an empty string.
    public let paymentDescription: String?

    /// The provider's Recreation.gov purchase URL text, including an empty string.
    public let recGovPurchaseUrl: String?

    private enum CodingKeys: String, CodingKey {
      case category
      case cost
      case description
      case exceptions
      case id
      case images = "image"
      case informationUrl
      case npsGovPurchaseUrl
      case payGovPurchaseUrl
      case paymentDescription
      case recGovPurchaseUrl
    }
  }

  /// A yearly season boundary, stored exactly as the provider sends it.
  ///
  /// Most dates carry a ``month`` and ``day``. Some carry only a ``holiday`` name, such as
  /// `"Memorial Day"`, with a null month and day; a floating holiday like Memorial Day falls on a
  /// different date each year and cannot be derived from its name, so no date is produced for that
  /// form. A few dates carry all three fields. No year is sent, so the caller supplies one along
  /// with the calendar and its time zone.
  ///
  /// ```swift
  /// var calendar = Calendar(identifier: .gregorian)
  /// calendar.timeZone = .gmt
  /// if let start = fee.startDate?.date(in: 2026, calendar: calendar) {
  ///   print(start)
  /// }
  /// ```
  public struct SeasonDate: Codable, Hashable, Sendable {
    /// The day of the month, or nil when the provider sends `null`.
    public let day: Int?

    /// The provider's holiday name, such as `"New Year’s Day"`, or nil when it sends `null`.
    public let holiday: String?

    /// The month number, or nil when the provider sends `null`.
    public let month: Int?

    /// The month and day, or nil unless both are present, including for a holiday-only date.
    public var dateComponents: DateComponents? {
      guard let month, let day else { return nil }
      return DateComponents(month: month, day: day)
    }

    /// Returns this month and day in a year, or nil when either is missing or the day does not
    /// exist in that month and year.
    ///
    /// A holiday-only date returns nil. An impossible day, such as February 30, returns nil
    /// rather than rolling into the next month.
    /// - Parameters:
    ///   - year: The year to place the date in.
    ///   - calendar: The calendar, including its time zone, used to build the date.
    /// - Returns: The start of the day in `calendar`, or nil.
    public func date(in year: Int, calendar: Calendar) -> Date? {
      guard let month, let day else { return nil }
      let components = DateComponents(year: year, month: month, day: day)
      guard let date = calendar.date(from: components) else { return nil }
      let resolved = calendar.dateComponents([.year, .month, .day], from: date)
      guard resolved.year == year, resolved.month == month, resolved.day == day else {
        return nil
      }
      return date
    }
  }

  /// The provider's cashless payment text, such as `"Yes"` or `"Depends on Location"`, kept as
  /// free text, including an empty string.
  public let cashless: String?

  /// The provider's display order for the park page's fee sections.
  public let contentOrderOrdinals: ContentOrderOrdinals?

  /// The provider's custom fee description, including an empty string.
  public let customFeeDescription: String?

  /// The provider's custom fee heading, including an empty string.
  public let customFeeHeading: String?

  /// The provider's custom fee link text, including an empty string.
  public let customFeeLinkText: String?

  /// The provider's custom fee link URL text, including an empty string.
  public let customFeeLinkUrl: String?

  /// The provider's entrance fee description, including an empty string.
  public let entranceFeeDescription: String?

  /// The provider's entrance pass description, including an empty string.
  public let entrancePassDescription: String?

  /// Published fees in the order sent, including an empty array.
  public let fees: [Fee]?

  /// The provider's "fees at work" URL text, including an empty string.
  public let feesAtWorkUrl: String?

  /// Whether the provider reports the park as charging no entrance fee.
  public let isFeeFreePark: Bool?

  /// Whether the provider reports the park as accepting interagency passes.
  public let isInteragencyPassAccepted: Bool?

  /// Whether the provider reports that a parking fee may apply.
  public let isParkingFeePossible: Bool?

  /// Whether the provider reports that a parking or transportation fee may apply.
  public let isParkingOrTransportationFeePossible: Bool?

  /// The provider's paid parking description, including an empty string.
  public let paidParkingDescription: String?

  /// The provider's paid parking heading, including an empty string.
  public let paidParkingHeading: String?

  /// The park code identifying the record, such as `"havo"`, kept as sent.
  public let parkCode: String

  /// The provider's parking details URL text, including an empty string.
  public let parkingDetailsUrl: String?

  /// Annual passes sold for the park, in the order sent, including an empty array.
  public let passes: [Pass]?

  /// Passes covering this park and others, in the order sent, including an empty array.
  public let relatedMultiSitePasses: [MultiSitePass]?

  /// The provider's timed entry description, including an empty string.
  public let timedEntryDescription: String?

  /// The provider's timed entry heading, including an empty string.
  public let timedEntryHeading: String?
}
