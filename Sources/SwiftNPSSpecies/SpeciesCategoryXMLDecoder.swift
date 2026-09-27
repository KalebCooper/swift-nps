import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import SwiftNPSSpeciesModels

/// A narrow decoder for the measured UTF-8 category document.
enum SpeciesCategoryXMLDecoder {
  private final class Delegate: NSObject, XMLParserDelegate {
    var descriptionText: String?
    var invalid = false
    var options: [SpeciesCategoryOption] = []
    var sawRoot = false
    var stack: [String] = []
    var text = ""
    var valueText: String?

    func parser(
      _ parser: XMLParser, didEndElement elementName: String,
      namespaceURI: String?, qualifiedName qName: String?
    ) {
      guard stack.last == elementName else { invalid = true; parser.abortParsing(); return }
      switch elementName {
      case "Description": descriptionText = text
      case "QueryOption":
        guard let descriptionText, let valueText else {
          invalid = true; parser.abortParsing(); return
        }
        options.append(SpeciesCategoryOption(description: descriptionText, value: valueText))
      case "Value": valueText = text
      default: break
      }
      stack.removeLast()
      text = ""
    }

    func parser(
      _ parser: XMLParser, didStartElement elementName: String,
      namespaceURI: String?, qualifiedName qName: String?,
      attributes attributeDict: [String: String]
    ) {
      switch (stack, elementName) {
      case ([], "ArrayOfQueryOption") where !sawRoot:
        sawRoot = true
      case (["ArrayOfQueryOption"], "QueryOption"):
        descriptionText = nil
        valueText = nil
      case (["ArrayOfQueryOption", "QueryOption"], "Description") where descriptionText == nil:
        break
      case (["ArrayOfQueryOption", "QueryOption"], "Value") where valueText == nil:
        break
      default:
        invalid = true
        parser.abortParsing()
        return
      }
      stack.append(elementName)
      text = ""
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
      guard let value = String(data: CDATABlock, encoding: .utf8) else {
        invalid = true; parser.abortParsing(); return
      }
      self.parser(parser, foundCharacters: value)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
      if stack.last == "Value" || stack.last == "Description" {
        text += string
      } else if !string.unicodeScalars.allSatisfy({ $0.properties.isWhitespace }) {
        invalid = true
        parser.abortParsing()
      }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
      invalid = true
    }

    func parser(
      _ parser: XMLParser, resolveExternalEntityName name: String,
      systemID: String?
    ) -> Data? {
      invalid = true
      return nil
    }
  }

  static func decode(_ data: Data) throws(NPSSpeciesError) -> [SpeciesCategoryOption] {
    guard let xml = String(data: data, encoding: .utf8),
      !xml.uppercased().contains("<!DOCTYPE"), !xml.uppercased().contains("<!ENTITY")
    else { throw .invalidCategoryResponse }
    let delegate = Delegate()
    let parser = XMLParser(data: data)
    parser.delegate = delegate
    parser.shouldProcessNamespaces = true
    parser.shouldResolveExternalEntities = false
    guard parser.parse(), !delegate.invalid, delegate.sawRoot, delegate.stack.isEmpty else {
      throw .invalidCategoryResponse
    }
    return delegate.options
  }
}
