import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park fees and passes", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkFeesAndPassesTests {
  private static func utcCalendar() throws -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    return calendar
  }

  @Test("The recorded search page decodes every top-level fees and passes field")
  func theRecordedSearchPageDecodesEveryTopLevelFeesAndPassesField() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkFeesAndPasses>.self, from: Fixture.parkFeesAndPassesSearch.data())
    #expect(page.total == "2")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(page.data.map(\.parkCode) == ["deva", "fova"])
    let park = try #require(page.data.first)
    #expect(park.cashless == "Yes")
    #expect(park.isFeeFreePark == false)
    #expect(park.isInteragencyPassAccepted == true)
    #expect(park.isParkingFeePossible == false)
    #expect(park.isParkingOrTransportationFeePossible == false)
    #expect(park.customFeeDescription == "")
    #expect(park.customFeeHeading == "")
    #expect(park.customFeeLinkText == "")
    #expect(park.customFeeLinkUrl == "")
    #expect(park.entranceFeeDescription == "")
    #expect(park.entrancePassDescription == "")
    #expect(park.feesAtWorkUrl == "")
    #expect(park.paidParkingDescription == "")
    #expect(park.paidParkingHeading == "")
    #expect(park.parkingDetailsUrl == "")
    #expect(park.timedEntryDescription == "")
    #expect(park.timedEntryHeading == "")
    #expect(park.relatedMultiSitePasses == [])
    let order = try #require(park.contentOrderOrdinals)
    #expect(order.customFee == 4)
    #expect(order.entranceFee == 1)
    #expect(order.paidParking == 3)
    #expect(order.timedEntry == 2)
  }

  @Test("Recorded fees keep their cost text, types, links, and seasons as sent")
  func recordedFeesKeepTheirCostTextTypesLinksAndSeasonsAsSent() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkFeesAndPasses>.self, from: Fixture.parkFeesAndPassesSearch.data())
    let fees = try #require(page.data.first?.fees)
    #expect(fees.count == 8)
    #expect(
      fees.map(\.cost) == ["30.00", "25.00", "15.00", "15.00", "100.00", "200.00", "15.00", "0.00"])
    let fee = try #require(fees.first)
    #expect(fee.id == "6200B376-0CB5-42D2-AA3B-4E4A2FC70B6A")
    #expect(fee.entranceFeeType == "Entrance - Private Vehicle")
    #expect(fee.informationUrl == "https://www.nps.gov/deva/planyourvisit/fees.htm")
    #expect(fee.recGovPurchaseUrl == "https://www.recreation.gov/sitepass/74277")
    #expect(fee.npsGovPurchaseUrl == "")
    #expect(fee.payGovPurchaseUrl == "")
    #expect(fee.timedEntryLocation == "")
    #expect(fee.timedEntryShortDescription == "")
    #expect(fee.startDate?.month == 1)
    #expect(fee.startDate?.day == 1)
    #expect(fee.startDate?.holiday == "New Year\u{2019}s Day")
    #expect(fee.endDate?.month == 12)
    #expect(fee.endDate?.day == 31)
    #expect(fee.endDate?.holiday == nil)
    #expect(fees.last?.startDate?.holiday == nil)
    let holidayOnly = try #require(page.data.last?.fees?.first)
    #expect(holidayOnly.cost == "10.00")
    #expect(holidayOnly.entranceFeeType == "Entrance - Per Person")
    #expect(holidayOnly.startDate?.month == nil)
    #expect(holidayOnly.startDate?.day == nil)
    #expect(holidayOnly.startDate?.holiday == "New Year\u{2019}s Day")
    #expect(holidayOnly.endDate?.holiday == "New Year\u{2019}s Day")
  }

  @Test("Recorded passes decode their images from the provider's image key")
  func recordedPassesDecodeTheirImagesFromTheProvidersImageKey() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkFeesAndPasses>.self, from: Fixture.parkFeesAndPassesSearch.data())
    let pass = try #require(page.data.last?.passes?.first)
    #expect(pass.id == "17404DBB-E3C1-4380-80A4-8F5AED5815A2")
    #expect(pass.category == "Annual Entrance - Park")
    #expect(pass.cost == "35.00")
    #expect(pass.exceptions == "")
    #expect(pass.informationUrl == "")
    #expect(pass.npsGovPurchaseUrl == "")
    #expect(pass.payGovPurchaseUrl == "")
    #expect(pass.paymentDescription == "")
    #expect(pass.recGovPurchaseUrl == "https://www.recreation.gov/camping/gateways/2708")
    #expect(pass.images?.count == 1)
    let image = try #require(pass.images?.first)
    #expect(image.credit == "NPS Photo")
    #expect(image.title == "Fort Vancouver National Historic Site")
    #expect(image.altText == "A park ranger guiding a group of visitors through Fort Vancouver.")
    #expect(
      image.url
        == "https://www.nps.gov/common/uploads/entrance_pass/"
        + "718D2A87-F14C-16B5-EC442D42B344D156.jpg")
    #expect(image.crops == nil)
    #expect(image.description == nil)
    let deva = try #require(page.data.first?.passes?.first)
    #expect(deva.paymentDescription == "Credit/Debit Only at all NPS locations")
    #expect(
      deva.images?.first?.url
        == "https://www.nps.gov/customcf/structured_data/images/add_image.png")
  }

  @Test("A recorded multi-site pass lists its related parks and an empty image array")
  func aRecordedMultiSitePassListsItsRelatedParksAndAnEmptyImageArray() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkFeesAndPasses>.self, from: Fixture.parkFeesAndPassesPageFirst.data())
    let park = try #require(page.data.first)
    #expect(park.parkCode == "havo")
    #expect(park.passes == [])
    #expect(park.fees?.count == 6)
    let pass = try #require(park.relatedMultiSitePasses?.first)
    #expect(pass.title == "Hawai'i Tri-Park Annual Pass")
    #expect(pass.type == "Multi-Site Pass")
    #expect(pass.cost == "55.00")
    #expect(pass.images == [])
    #expect(pass.audience?.hasPrefix("Visitors who will only visit Hawai'i Volcanoes") == true)
    #expect(pass.description?.hasPrefix("Valid for 12 months from purchase month.") == true)
    #expect(pass.relatedParks?.map(\.parkCode) == ["hale", "havo", "puho"])
    let related = try #require(pass.relatedParks?.first)
    #expect(related.fullName == "Haleakal\u{0101} National Park")
    #expect(related.states == "HI")
    #expect(related.url == "https://www.nps.gov/hale/index.htm")
  }

  @Test("The image key round-trips under its provider spelling")
  func theImageKeyRoundTripsUnderItsProviderSpelling() throws {
    let json = Data(
      #"{"parkCode": "x", "passes": [{"image": []}], "relatedMultiSitePasses": [{"image": []}]}"#
        .utf8)
    let park = try JSONDecoder().decode(ParkFeesAndPasses.self, from: json)
    let encoded = try JSONEncoder().encode(park)
    let object = try #require(
      try JSONSerialization.jsonObject(with: encoded) as? [String: Any])
    let pass = try #require((object["passes"] as? [[String: Any]])?.first)
    #expect(pass.keys.sorted() == ["image"])
    let multi = try #require((object["relatedMultiSitePasses"] as? [[String: Any]])?.first)
    #expect(multi.keys.sorted() == ["image"])
  }

  @Test("Season date components need both a month and a day")
  func seasonDateComponentsNeedBothAMonthAndADay() throws {
    let decoder = JSONDecoder()
    let full = try decoder.decode(
      ParkFeesAndPasses.SeasonDate.self,
      from: Data(#"{"month": 1, "day": 1, "holiday": "New Year’s Day"}"#.utf8))
    #expect(full.dateComponents == DateComponents(month: 1, day: 1))
    let holidayOnly = try decoder.decode(
      ParkFeesAndPasses.SeasonDate.self,
      from: Data(#"{"month": null, "day": null, "holiday": "Memorial Day"}"#.utf8))
    #expect(holidayOnly.dateComponents == nil)
    #expect(holidayOnly.holiday == "Memorial Day")
    let monthOnly = try decoder.decode(
      ParkFeesAndPasses.SeasonDate.self, from: Data(#"{"month": 5}"#.utf8))
    #expect(monthOnly.dateComponents == nil)
  }

  @Test("Season dates resolve in a caller year and calendar, refusing impossible days")
  func seasonDatesResolveInACallerYearAndCalendarRefusingImpossibleDays() throws {
    let calendar = try Self.utcCalendar()
    let decoder = JSONDecoder()
    let endOfYear = try decoder.decode(
      ParkFeesAndPasses.SeasonDate.self, from: Data(#"{"month": 12, "day": 31}"#.utf8))
    let date = try #require(endOfYear.date(in: 2026, calendar: calendar))
    // 2026-12-31T00:00:00Z.
    #expect(date == Date(timeIntervalSince1970: 1_798_675_200))
    let leapDay = try decoder.decode(
      ParkFeesAndPasses.SeasonDate.self, from: Data(#"{"month": 2, "day": 29}"#.utf8))
    #expect(leapDay.date(in: 2024, calendar: calendar) != nil)
    #expect(leapDay.date(in: 2025, calendar: calendar) == nil)
    let impossible = try decoder.decode(
      ParkFeesAndPasses.SeasonDate.self, from: Data(#"{"month": 2, "day": 30}"#.utf8))
    #expect(impossible.date(in: 2025, calendar: calendar) == nil)
    let holidayOnly = try decoder.decode(
      ParkFeesAndPasses.SeasonDate.self, from: Data(#"{"holiday": "Memorial Day"}"#.utf8))
    #expect(holidayOnly.date(in: 2026, calendar: calendar) == nil)
  }

  @Test("Missing optional fields decode to nil while a missing park code fails")
  func missingOptionalFieldsDecodeToNilWhileAMissingParkCodeFails() throws {
    let park = try JSONDecoder().decode(
      ParkFeesAndPasses.self, from: Data(#"{"parkCode": "x"}"#.utf8))
    #expect(park.cashless == nil)
    #expect(park.contentOrderOrdinals == nil)
    #expect(park.fees == nil)
    #expect(park.isFeeFreePark == nil)
    #expect(park.passes == nil)
    #expect(park.relatedMultiSitePasses == nil)
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(ParkFeesAndPasses.self, from: Data(#"{"fees": []}"#.utf8))
    }
  }

  @Test("The recorded empty page decodes with no fees and passes records")
  func theRecordedEmptyPageDecodesWithNoFeesAndPassesRecords() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkFeesAndPasses>.self, from: Fixture.parkFeesAndPassesEmpty.data())
    #expect(page.total == "0")
    #expect(page.data.isEmpty)
  }
}
