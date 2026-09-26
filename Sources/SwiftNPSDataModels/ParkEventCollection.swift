#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// Either an ordinary events page or the provider's bare array of expanded occurrences.
///
/// No pagination metadata is invented for expanded arrays. Inspect ``page`` before reading
/// metadata, and inspect its errors before interpreting a response as successful.
/// Expanded occurrences retain repeated identifiers and provider order.
public enum ParkEventCollection: Codable, Hashable, Sendable {
  /// A JSON value preserved only for the events envelope's undocumented error entries.
  public indirect enum ErrorValue: Codable, Hashable, Sendable {
    /// An ordered array of error values.
    case array([ErrorValue])
    /// A JSON Boolean.
    case boolean(Bool)
    /// JSON null.
    case null
    /// A JSON number represented as a decimal.
    case number(Decimal)
    /// An object with its original keys.
    case object([String: ErrorValue])
    /// An error string.
    case string(String)

    /// Decodes one error value without assuming an undocumented schema.
    /// - Parameter decoder: The decoder positioned at the value.
    public init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()
      if container.decodeNil() {
        self = .null
      } else if let value = try? container.decode(Bool.self) {
        self = .boolean(value)
      } else if let value = try? container.decode(String.self) {
        self = .string(value)
      } else if let value = try? container.decode(Decimal.self) {
        self = .number(value)
      } else if let value = try? container.decode([ErrorValue].self) {
        self = .array(value)
      } else {
        self = .object(try container.decode([String: ErrorValue].self))
      }
    }

    /// Encodes the preserved error value.
    /// - Parameter encoder: The destination encoder.
    public func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .array(let value): try container.encode(value)
      case .boolean(let value): try container.encode(value)
      case .null: try container.encodeNil()
      case .number(let value): try container.encode(value)
      case .object(let value): try container.encode(value)
      case .string(let value): try container.encode(value)
      }
    }
  }

  /// The ordinary event envelope with raw string pagination metadata.
  public struct Page: Codable, Hashable, Sendable {
    /// Event definitions in provider order.
    public let data: [ParkEvent]
    /// Reported errors; populated entries have no verified provider schema.
    public let errors: [ErrorValue]
    /// The provider's one-based page number text.
    public let pageNumber: String
    /// The provider's page size text.
    public let pageSize: String
    /// The provider's event-definition count text.
    public let total: String

    private enum CodingKeys: String, CodingKey {
      case data, errors
      case pageNumber = "pagenumber"
      case pageSize = "pagesize"
      case total
    }
  }

  /// A bare array returned when provider recurrence expansion is enabled.
  case expanded([ParkEvent])
  /// An ordinary page with provider metadata.
  case page(Page)

  /// Decodes either wire shape without manufacturing an envelope.
  /// - Parameter decoder: The decoder for the response body.
  public init(from decoder: any Decoder) throws {
    if var array = try? decoder.unkeyedContainer() {
      var events: [ParkEvent] = []
      while !array.isAtEnd { events.append(try array.decode(ParkEvent.self)) }
      self = .expanded(events)
    } else {
      self = .page(try Page(from: decoder))
    }
  }

  /// All events or occurrences in this response, in provider order.
  public var data: [ParkEvent] {
    switch self {
    case .expanded(let events): events
    case .page(let page): page.data
    }
  }

  /// The ordinary envelope, or nil when expansion omitted metadata.
  public var page: Page? {
    guard case .page(let page) = self else { return nil }
    return page
  }

  /// Encodes the original response shape.
  /// - Parameter encoder: The destination encoder.
  public func encode(to encoder: any Encoder) throws {
    switch self {
    case .expanded(let events):
      var container = encoder.unkeyedContainer()
      for event in events { try container.encode(event) }
    case .page(let page): try page.encode(to: encoder)
    }
  }
}
