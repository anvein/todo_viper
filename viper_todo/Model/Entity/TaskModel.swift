
import Foundation

class TaskModel {
    var id: String?
    var title: String
    var description: String?
    var isCompleted: Bool
    var createdAt: Date?

    init(
        id: String? = nil,
        title: String,
        description: String? = nil,
        isCompleted: Bool,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
