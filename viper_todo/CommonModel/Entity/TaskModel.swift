
import Foundation

class TaskModel {
    var id: UUID?
    var title: String
    var description: String?
    var isCompleted: Bool
    var createdAt: Date?

    init(
        id: UUID? = nil,
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

    init(cdTask: CDTask) {
        self.id = cdTask.id
        self.title = cdTask.title ?? "No title"
        self.description = cdTask.descriptionText
        self.isCompleted = cdTask.isCompleted
        self.createdAt = cdTask.createdAt
    }
}
