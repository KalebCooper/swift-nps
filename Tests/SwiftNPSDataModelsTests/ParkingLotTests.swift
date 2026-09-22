import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Parking lots", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkingLotTests {
  @Test("The recorded search page decodes every parking lot field")
  func theRecordedSearchPageDecodesEveryParkingLotField() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkingLot>.self, from: Fixture.parkingLotsSearch.data())
    #expect(page.total == "2")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    #expect(page.data.count == 2)
    let lot = try #require(page.data.first)
    #expect(lot.id == "A4446AB4-5566-4F6C-B218-5ED4F7C0D447")
    #expect(lot.name == "K\u{012B}lauea Iki Overlook Parking Lot")
    #expect(lot.altName == "")
    #expect(
      lot.description
        == "K\u{012B}lauea Iki Overlook is often used to access the K\u{012B}lauea Iki Trail and "
        + "Nahuku (Thurston Lava Tube).")
    #expect(lot.latitude == 19.416584)
    #expect(lot.longitude == -155.242891)
    #expect(lot.geometryPoiId == "")
    #expect(lot.timeZone == "HAST")
    #expect(lot.webcamUrl == "")
    #expect(lot.fees == [])
    #expect(lot.contacts?.phoneNumbers == [])
    let email = try #require(lot.contacts?.emailAddresses?.first)
    #expect(email.description == "Visitor information")
    #expect(email.emailAddress == "havo_information@nps.gov")
    let park = try #require(lot.relatedParks?.first)
    #expect(park.parkCode == "havo")
    #expect(park.states == "HI")
    #expect(park.designation == "National Park")
    #expect(park.url == "https://www.nps.gov/havo/index.htm")
    let hours = try #require(lot.operatingHours?.first)
    #expect(hours.name == "K\u{012B}lauea Iki")
    #expect(hours.description == "")
    #expect(hours.exceptions == [])
    #expect(hours.standardHours?.count == 7)
    #expect(hours.standardHours?["monday"] == "All Day")
    #expect(lot.images?.count == 7)
    let image = try #require(lot.images?.first)
    #expect(image.credit == "NPS Photo/Ed Shiinoki")
    #expect(image.title == "K\u{012B}lauea Iki Entrance")
    #expect(
      image.url
        == "https://www.nps.gov/common/uploads/structured_data/"
        + "C547E58A-CC2E-E02B-27074BFB053ABAC8.jpg")
    #expect(image.crops == nil)
    #expect(image.description == nil)
    let accessibility = try #require(lot.accessibility)
    #expect(accessibility.isLotAccessibleToDisabled == true)
    #expect(accessibility.totalSpaces == 64)
    #expect(accessibility.numberOfAdaSpaces == 3)
    #expect(accessibility.adaFacilitiesDescription == "")
    let status = try #require(lot.liveStatus)
    #expect(status.isActive == true)
    #expect(status.occupancy == "")
    #expect(status.estimatedWaitTimeInMinutes == nil)
    #expect(status.description == "")
    #expect(status.expirationDate == "")
    let second = page.data[1]
    #expect(second.id == "D44DB7B9-74D1-4BDE-91CF-B2338EA69897")
    #expect(second.contacts?.emailAddresses == [])
    #expect(second.liveStatus?.occupancy == "Light")
    #expect(second.liveStatus?.estimatedWaitTimeInMinutes == 0)
    #expect(second.accessibility?.isLotAccessibleToDisabled == false)
    #expect(second.accessibility?.numberOfOversizeVehicleSpaces == 2)
  }

  @Test("Managing organization text keeps the provider's differing apostrophes")
  func managingOrganizationTextKeepsTheProvidersDifferingApostrophes() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkingLot>.self, from: Fixture.parkingLotsSearch.data())
    // The provider spells the same park with a left single quotation mark and with an okina.
    #expect(
      page.data.map(\.managedByOrganization) == [
        "Hawai\u{2018}i Volcanoes National Park", "Hawai\u{02BB}i Volcanoes National Park",
      ])
  }

  @Test("Provider accessibility keys decode and encode with their spelling and casing")
  func providerAccessibilityKeysDecodeAndEncodeWithTheirSpellingAndCasing() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkingLot>.self, from: Fixture.parkingLotsPageFirst.data())
    let lot = try #require(page.data.first)
    #expect(lot.id == "FBB7FD7A-A735-4C34-AFBD-787548F71F5B")
    #expect(lot.name == "Magnolia Mobil Gas Station")
    let accessibility = try #require(lot.accessibility)
    #expect(accessibility.totalSpaces == 9)
    #expect(accessibility.numberOfAdaSpaces == 1)
    #expect(accessibility.numberOfAdaStepFreeSpaces == 1)
    #expect(accessibility.numberOfAdaVanAccessibleSpaces == 1)
    #expect(accessibility.numberOfOversizeVehicleSpaces == 0)
    let encoded = try JSONEncoder().encode(accessibility)
    let object = try #require(try JSONSerialization.jsonObject(with: encoded) as? [String: Any])
    #expect(
      Set(object.keys) == [
        "adaFacilitiesDescription", "isLotAccessibleToDisabled", "numberOfOversizeVehicleSpaces",
        "numberofAdaSpaces", "numberofAdaStepFreeSpaces", "numberofAdaVanAccessbileSpaces",
        "totalSpaces",
      ])
    #expect(try JSONDecoder().decode(ParkingLot.Accessibility.self, from: encoded) == accessibility)
  }

  @Test("Shared contact, fee, and hour shapes decode from the recorded page")
  func sharedContactFeeAndHourShapesDecodeFromTheRecordedPage() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkingLot>.self, from: Fixture.parkingLotsPageFirst.data())
    let lot = try #require(page.data.first)
    #expect(lot.latitude == 34.73729)
    #expect(lot.longitude == -92.297253)
    #expect(lot.timeZone == "CT")
    #expect(lot.managedByOrganization == "Little Rock Central High School NHS")
    let fee = try #require(lot.fees?.first)
    #expect(fee.cost == "0.00")
    #expect(fee.title == "Fee free parking")
    #expect(
      fee.description == "Free parking - parking allowed only during the duration of your visit")
    #expect(lot.contacts?.phoneNumbers?.map(\.type) == ["Voice", "Fax"])
    #expect(lot.contacts?.phoneNumbers?.map(\.phoneNumber) == ["501-374-1957", "501-396-3001"])
    #expect(lot.contacts?.phoneNumbers?.first?.extension == "")
    #expect(lot.contacts?.emailAddresses?.map(\.emailAddress) == ["chsc_info@nps.gov"])
    let hours = try #require(lot.operatingHours?.first)
    #expect(hours.name == "Magnolia/Mobil Station")
    #expect(hours.standardHours?["sunday"] == "8:30AM - 5:00PM")
  }

  @Test("A stale status report and empty exception hours are kept as sent")
  func aStaleStatusReportAndEmptyExceptionHoursAreKeptAsSent() throws {
    let json = Data(
      """
      {
        "id": "X", "name": "Lot",
        "operatingHours": [{
          "exceptions": [{
            "endDate": "2025-05-24", "exceptionHours": {}, "name": "Spring",
            "startDate": "2025-04-17"
          }]
        }],
        "liveStatus": {
          "description": "Expect busy parking.", "estimatedWaitTimeInMinutes": 30,
          "expirationDate": "2019-11-25 14:00:00.0", "isActive": false, "occupancy": "Very Busy"
        }
      }
      """.utf8)
    let lot = try JSONDecoder().decode(ParkingLot.self, from: json)
    let status = try #require(lot.liveStatus)
    #expect(status.expirationDate == "2019-11-25 14:00:00.0")
    #expect(status.occupancy == "Very Busy")
    #expect(status.estimatedWaitTimeInMinutes == 30)
    #expect(status.isActive == false)
    #expect(status.description == "Expect busy parking.")
    let exception = try #require(lot.operatingHours?.first?.exceptions?.first)
    #expect(exception.exceptionHours == [:])
    #expect(exception.startDate == "2025-04-17")
  }

  @Test("Missing optional fields decode to nil while a missing name fails")
  func missingOptionalFieldsDecodeToNilWhileAMissingNameFails() throws {
    let lot = try JSONDecoder().decode(
      ParkingLot.self, from: Data(#"{"id": "X", "name": "Lot"}"#.utf8))
    #expect(lot.accessibility == nil)
    #expect(lot.contacts == nil)
    #expect(lot.fees == nil)
    #expect(lot.images == nil)
    #expect(lot.latitude == nil)
    #expect(lot.liveStatus == nil)
    #expect(lot.operatingHours == nil)
    #expect(lot.relatedParks == nil)
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(ParkingLot.self, from: Data(#"{"id": "X"}"#.utf8))
    }
  }

  @Test("The recorded empty page decodes with no parking lots")
  func theRecordedEmptyPageDecodesWithNoParkingLots() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ParkingLot>.self, from: Fixture.parkingLotsEmpty.data())
    #expect(page.total == "0")
    #expect(page.data.isEmpty)
  }
}
