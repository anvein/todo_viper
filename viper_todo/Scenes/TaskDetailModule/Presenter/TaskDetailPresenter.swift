
import Foundation

final class TaskDetailPresenter {

    // MARK: - MVP components

    private let model: TaskDetailModel
    private weak var view: TaskDetailViewProtocol?
    private var moduleOutput: TaskDetailModuleOutput?

    // MARK: - Init

    init(model: TaskDetailModel) {
        self.model = model
    }

    // MARK: - Injection

    func setView(_ view: TaskDetailViewProtocol?) {
        self.view = view
    }

    func setModuleOutput(_ moduleOutput: TaskDetailModuleOutput?) {
        self.moduleOutput = moduleOutput
    }

}

// MARK: - TaskDetailPresenterProtocol

extension TaskDetailPresenter: TaskDetailPresenterProtocol {

    func viewDidLoad() {
        let task = model.getTask()
        let taskDetailDto = buildTaskDetailDtoFrom(task: task)

        view?.setTaskData(task: taskDetailDto)
    }

    func didTapIsDoneButton() {
        let task = model.updateAndSwitchTaskIsCompletedField()
        view?.setTaskIsCompleted(task.isCompleted)
    }

    func didEndEditTaskTitle(_ title: String) {
        let preparedTitle = title.replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)

        guard !preparedTitle.isEmpty else {
            let task = model.getTask()
            view?.setTaskTitle(task.title)
            return
        }

        let task = model.updateTaskField(title: preparedTitle)
        view?.setTaskTitle(task.title)
    }

    func didEndEditTaskDescription(_ text: String?) {
        let preparedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)

        let task = model.updateTaskField(description: preparedText)
        view?.setTaskDescription(task.description ?? "")
    }

    func didCloseTaskDetail() {
        moduleOutput?.taskDetailModuleDidClose(taskId: model.taskId)
    }

}

private extension TaskDetailPresenter {

    // MARK: - Helpers

    func buildTaskDetailDtoFrom(task: TaskModel) -> TaskDetailDto {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy, HH:mm"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        var dateAsString: String? = nil
        if let createdAt = task.createdAt {
            dateAsString = dateFormatter.string(from: createdAt)
        }

        return TaskDetailDto(
            title: task.title,
            isCompleted: task.isCompleted,
            descriptionText: task.description ?? "",
            createdAt: dateAsString
        )
    }

}
