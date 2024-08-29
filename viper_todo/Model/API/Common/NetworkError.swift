
import Foundation

enum NetworkError: Error {
    case invalidUrl
    case noData
    case invalidResponse
    case parsingResponseError
    case undefinedError(text: String)
}
