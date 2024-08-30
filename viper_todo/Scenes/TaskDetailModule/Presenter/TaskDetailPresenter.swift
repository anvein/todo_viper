
import Foundation

final class TaskDetailPresenter {

    // MARK: - Services

    private let taskCDManager: TaskCoreDataManager

    // MARK: - View / Presenter

    private weak var view: TaskDetailViewProtocol?
    private var moduleOutput: TaskDetailModuleOutput?

    // MARK: - State

    private var taskModel: TaskModel?
    private let taskId: UUID

    // MARK: - Init

    init(
        taskId: UUID,
        taskCDManager: TaskCoreDataManager = .init()
    ) {
        self.taskCDManager = taskCDManager
        self.taskId = taskId
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
        guard let cdTask = taskCDManager.getTaskBy(id: taskId) else { return }

        let taskModel = TaskModel(cdTask: cdTask)
        self.taskModel = taskModel
        let taskDetailDto = buildTaskDetailDtoFrom(taskModel: taskModel)

        view?.setTaskData(task: taskDetailDto)
    }

    func didTapIsDoneButton() {
        guard let taskModel,
              let taskId = taskModel.id,
              let taskCDModel = taskCDManager.getTaskBy(id: taskId) else { return }

        let newValue = !taskModel.isCompleted

        taskCDManager.updateField(isCompleted: newValue, task: taskCDModel)
        taskModel.isCompleted = newValue

        view?.setTaskIsCompleted(newValue)
    }

    func didEndEditTaskTitle(_ title: String) {
        guard let taskModel,
              let taskId = taskModel.id,
              let cdTaskModel = taskCDManager.getTaskBy(id: taskId) else { return }

        let preparedTitle = title.replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespaces)

        guard !preparedTitle.isEmpty else {
            view?.setTaskTitle(taskModel.title)
            return
        }

        taskCDManager.updateField(title: preparedTitle, task: cdTaskModel)
        taskModel.title = preparedTitle

        view?.setTaskTitle(preparedTitle)
    }

    func didEndEditTaskDescription(_ text: String?) {
        guard let taskModel,
              let taskId = taskModel.id,
              let cdTaskModel = taskCDManager.getTaskBy(id: taskId) else { return }

        let preparedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)

        taskCDManager.updateField(descriptionText: preparedText, task: cdTaskModel)
        taskModel.description = preparedText

        view?.setTaskDescription(preparedText ?? "")
    }

    func didCloseTaskDetail() {
        moduleOutput?.taskDetailModuleDidClose(taskId: taskId)
    }

}

private extension TaskDetailPresenter {

    // MARK: - Helpers

    func buildTaskDetailDtoFrom(taskModel: TaskModel) -> TaskDetailDto {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy, HH:mm"

        var dateAsString: String? = nil
        if let createdAt = taskModel.createdAt {
            dateAsString = dateFormatter.string(from: createdAt)
        }

        return TaskDetailDto(
            title: taskModel.title,
            isCompleted: taskModel.isCompleted,
            descriptionText: taskModel.description ?? "",
            createdAt: dateAsString
        )
    }

}
