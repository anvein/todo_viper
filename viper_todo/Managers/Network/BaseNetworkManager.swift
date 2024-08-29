
import Foundation

class BaseNetworkManager {

    private let urlSession: URLSession

    // MARK: - Init

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // MARK: - Base methods

    func getData<T: ApiResponse> (
        route: ApiRoute,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        do {
            let request = try route.buildRequest()

            urlSession.dataTask(with: request) { data, response, error in
                if let error {
                    completion(.failure(NetworkError.undefinedError(text: error.localizedDescription)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }

                guard let data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                guard let response = try? JSONDecoder().decode(T.self, from: data) else {
                    completion(.failure(NetworkError.parsingResponseError))
                    return
                }

                completion(.success(response))
            }.resume()
        } catch let error as NetworkError {
            completion(.failure(error))
        } catch {
            completion(.failure(NetworkError.undefinedError(text: error.localizedDescription)))
        }
    }
}
