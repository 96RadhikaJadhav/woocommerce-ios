import XCTest
@testable import Networking

extension MockupNetwork {
    /// Returns the parameters ("\(key)=\(value)") for the WC API path in the first network request URL.
    var pathComponents: [String]? {
        guard let request = requestsForResponseData.first,
            let urlRequest = try? request.asURLRequest(),
            let url = urlRequest.url,
            requestsForResponseData.count == 1 else {
                return nil
        }
        guard let urlComponents = URLComponents(string: url.absoluteString) else {
            return nil
        }
        let parameters = urlComponents.queryItems

        guard let path = parameters?.first(where: { $0.name == "path" })?.value else {
            return nil
        }
        return path.components(separatedBy: "&")
    }
}
