
import Foundation

protocol ApiRoute {
    var host: String { get }
    var endpoint: String { get }
    var queryParams: [URLQueryItem]? { get }
    var method: APIHttpMethod { get }
    var headers: [String: String]? { get }

    func buildRequest() throws -> URLRequest
}

extension ApiRoute {
    func buildRequest() throws -> URLRequest {
        guard var url = URL(string: host + endpoint) else {
            throw NetworkError.invalidUrl
        }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryParams

        url = urlComponents?.url ?? url

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}

