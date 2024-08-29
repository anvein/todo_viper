
import Foundation

enum ADRoute: ApiRoute {
    // MARK: - Cases

    case tasksList(page: Int, itemsPerPage: Int)
    case task(taskId: Int)

    // MARK: - Route Params

    var host: String { "https://dummyjson.com" }

    var endpoint: String {
        switch self {
        case .tasksList: return "/todos"
        case .task(let taskId): return "/todos/\(taskId)"
        }
    }

    var queryParams: [URLQueryItem]? {
        switch self {
        case .tasksList(let page, let itemsPerPage):
            let skip = (page - 1) * itemsPerPage
            return [
                .init(name: "skip", value: String(skip)),
                .init(name: "limit", value: String(itemsPerPage)),
            ]
        case .task(_):
            return nil
        }
    }

    var method: APIHttpMethod {
        switch self {
        case .task(_), .tasksList(_, _) :
            return .get
        }
    }

    var headers: [String : String]? {
        switch self {
        case .task(_), .tasksList(_, _) :
            return nil
        }
    }

}
