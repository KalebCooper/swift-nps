/// One unencoded query parameter of a collection request.
///
/// A parameter carries one or more values. ``Endpoint/collection(_:)`` percent-encodes each value
/// separately and joins them with a literal comma, which is how NPS delimits list parameters, so
/// a comma inside a value is always escaped. Names are literal parameter names and are not encoded.
public struct NPSQueryItem: Hashable, Sendable {
  /// The parameter name exactly as NPS documents it, such as `parkCode`.
  public let name: String
  /// The unencoded values in caller order; one value for a scalar parameter.
  public let values: [String]

  /// Creates a scalar parameter.
  /// - Parameters:
  ///   - name: The parameter name.
  ///   - value: The unencoded value.
  public init(name: String, value: String) {
    self.name = name
    self.values = [value]
  }

  /// Creates a list parameter.
  /// - Parameters:
  ///   - name: The parameter name.
  ///   - values: The unencoded values, joined with commas when serialized.
  public init(name: String, values: [String]) {
    self.name = name
    self.values = values
  }

  var encoded: String {
    name + "=" + values.map(Self.encode).joined(separator: ",")
  }

  private static func encode(_ value: String) -> String {
    value.utf8.map { byte in
      if (48...57).contains(byte) || (65...90).contains(byte) || (97...122).contains(byte)
        || [45, 46, 95, 126].contains(byte)
      {
        return String(UnicodeScalar(byte))
      }
      let hex = String(byte, radix: 16, uppercase: true)
      return "%" + (hex.count == 1 ? "0" : "") + hex
    }.joined()
  }
}
