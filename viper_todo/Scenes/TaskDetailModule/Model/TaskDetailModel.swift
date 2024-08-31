
import Foundation

final class TaskDetailModel {

    // MARK: - Services

    private let taskCDService: TaskCoreDataService

    // MARK: - State

    private lazy var cdTask: CDTask = self.getTaskWith(taskId: taskId)
    let taskId: UUID

    // MARK: - Init

    init(taskId: UUID, taskCDService: TaskCoreDataService) {
        self.taskId = taskId
        self.taskCDService = taskCDService
    }

    // MARK: - Get

    func getTask() -> TaskModel {
        return TaskModel(cdTask: cdTask)
    }

    // MARK: - Update

    func updateAndSwitchTaskIsCompletedField() -> TaskModel {
        let newValue = !cdTask.isCompleted
        taskCDService.updateField(isCompleted: newValue, task: cdTask)
        return TaskModel(cdTask: cdTask)
    }

    func updateTaskField(title: String) -> TaskModel {
        taskCDService.updateField(title: title, task: cdTask)
        return TaskModel(cdTask: cdTask)
    }

    func updateTaskField(description: String?) -> TaskModel {
        taskCDService.updateField(descriptionText: description, task: cdTask)
        return TaskModel(cdTask: cdTask)
    }

}

// MARK: - Helpers

private extension TaskDetailModel {
    func getTaskWith(taskId: UUID) -> CDTask {
        if let task = taskCDService.getTaskBy(id: taskId) {
            return task
        } else {
            fatalError("Task with id = \(taskId) not found")
            // TODO: бросить исключение, что задача не найдена
        }
    }
}
