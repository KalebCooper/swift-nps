/// Filters for County, SiteCounties, LandmarkInformation, and LandmarkInformationWithCounty.
/// Omitted values are not sent.
public struct LandmarkQuery: Hashable, Sendable {
  /// Invalid filters are rejected rather than silently broadening a search.
  public enum ValidationError: Error, Hashable, Sendable {
    /// IDs must fit 1...Int32.max; invalid provider values can mean an unfiltered request.
    case invalidIdentifier
    /// Empty or control-containing text.
    case invalidText
  }

  /// The provider's landmark Code.
  public let code: String?
  /// The provider's county identifier, distinct from ID.
  public let countyID: Int64?
  /// The landmark ID.
  public let id: Int64?
  /// Raw service state code; independent of the NPS Data API's state vocabulary.
  public let stateCode: String?

  /// Creates filters without trimming, case folding, or substituting identifiers.
  public init(
    code: String? = nil, countyID: Int64? = nil, id: Int64? = nil, stateCode: String? = nil
  ) throws(ValidationError) {
    for value in [code, stateCode].compactMap({ $0 }) {
      guard value.unicodeScalars.contains(where: { !$0.properties.isWhitespace }),
        !value.unicodeScalars.contains(where: { $0.value < 32 || $0.value == 127 })
      else { throw .invalidText }
    }
    guard [countyID, id].compactMap({ $0 }).allSatisfy({ $0 > 0 && $0 <= Int32.max }) else {
      throw .invalidIdentifier
    }
    self.code = code
    self.countyID = countyID
    self.id = id
    self.stateCode = stateCode
  }

  var encodedQuery: String {
    let pairs: [(String, String?)] = [
      ("Code", code), ("CountyID", countyID.map(String.init)), ("ID", id.map(String.init)),
      ("StateCode", stateCode),
    ]
    return pairs.compactMap { name, value in value.map { name + "=" + Self.encode($0) } }.joined(
      separator: "&")
  }

  private static func encode(_ value: String) -> String {
    value.utf8.map { byte in
      switch byte {
      case 45, 46, 48...57, 65...90, 95, 97...122, 126: return String(UnicodeScalar(byte))
      default:
        let hex = String(byte, radix: 16, uppercase: true)
        return "%" + (hex.count == 1 ? "0" : "") + hex
      }
    }.joined()
  }
}
