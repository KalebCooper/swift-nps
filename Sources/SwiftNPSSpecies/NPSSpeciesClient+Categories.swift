import HTTPCore
import HTTPTypes
import SwiftNPSSpeciesModels

extension NPSSpeciesClient {
  /// Fetches raw category guidance using the provider's XML representation.
  /// - Throws: Transport failures or invalidCategoryResponse for unsupported XML.
  public func categoryOptions() async throws(NPSSpeciesError) -> [SpeciesCategoryOption] {
    try await value(for: SpeciesCategoriesRequest())
  }

  /// Sends the concrete XML operation without using the JSON decoder.
  /// - Parameter endpoint: The fixed category endpoint.
  /// - Throws: Transport failures or invalidCategoryResponse.
  public func send(_ endpoint: SpeciesCategoriesEndpoint) async throws(NPSSpeciesError)
    -> [SpeciesCategoryOption]
  {
    guard !Task.isCancelled else { throw .transport(.cancelled) }
    let response: Response
    do throws(TransportError) {
      response = try await client.execute(
        Request(headers: [.accept: endpoint.accept], path: endpoint.path))
    } catch { throw .transport(error) }
    guard !Task.isCancelled else { throw .transport(.cancelled) }
    let options = try SpeciesCategoryXMLDecoder.decode(response.body)
    guard !Task.isCancelled else { throw .transport(.cancelled) }
    return options
  }

  /// Executes a concrete category request.
  /// - Parameter request: The inspectable XML operation.
  /// - Throws: The same failures as the category endpoint overload.
  public func value(for request: SpeciesCategoriesRequest) async throws(NPSSpeciesError)
    -> [SpeciesCategoryOption]
  {
    try await send(request.endpoint)
  }
}
