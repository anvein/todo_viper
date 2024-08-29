
import Foundation

struct ADTasksResponse: ApiResponse {
    var tasks: [ADTask] = []
    var total: Int
    var skip: Int
    var limit: Int

    enum CodingKeys: String, CodingKey {
        case tasks = "todos"
        case total
        case skip
        case limit
    }
}

// MARK: - TasksResponse.ADTask

extension ADTasksResponse {
    struct ADTask: Decodable {
        var title: String
        var isCompleted: Bool

        enum CodingKeys: String, CodingKey {
            case title = "todo"
            case isCompleted = "completed"
        }
    }
}
