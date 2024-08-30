
import Foundation

final class TasksListPresenter {

    // MARK: - Services

    private let defaultsManager: UserDefaultsManager
    private let taskCDManager: TaskCoreDataManager
    private let initialDataLoader: InitialDataLoader

    // MARK: - View

    private weak var view: TasksListViewType?

    // MARK: - Model

    private var tasks: [TaskSectionKey.RawValue: [TaskModel]] = [:]
    private var selectedTaskIndexPath: IndexPath?

    // MARK: - Init

    init(
        defaultsManager: UserDefaultsManager = .shared,
        taskCDManager: TaskCoreDataManager = .init(),
        initialDataLoader: InitialDataLoader = .init()
    ) {
        self.defaultsManager = defaultsManager
        self.taskCDManager = taskCDManager
        self.initialDataLoader = initialDataLoader
    }

    // MARK: - Injection

    func setView(_ view: TasksListViewType) {
        self.view = view
    }
}

// MARK: - TasksListPresenterType

extension TasksListPresenter: TasksListPresenterType {

    func viewDidLoad() {
        if !defaultsManager.getIsTasksFirstLoad() {
            // TODO: установить лоадер

            initialDataLoader.loadData() { [weak self] in
                self?.defaultsManager.setIsTasksFirstLoad(true)
                self?.loadTasksFromDB()
                self?.view?.reloadTableData()
                // скрыть лоадер
            } errorCompletionHandler: {
                
            }
        } else {
            loadTasksFromDB()
        }
    }

    func getSectionsCount() -> Int {
        return tasks.count
    }

    func getTasksCountIn(sectionIndex: Int) -> Int {
        guard let sectionKey = getTaskSectionKeyFor(sectionIndex: sectionIndex) else { return 0 }
        return tasks[sectionKey.rawValue]?.count ?? 0
    }

    func getTaskCellFor(indexPath: IndexPath) -> TaskCellDto? {
        guard let task = getTaskModelFor(indexPath: indexPath) else { return nil }
        return buildTaskCellDtoFrom(taskModel: task)
    }

    func didTapIsDoneButtonInCellWith(indexPath: IndexPath) {
        guard let taskModel = getTaskModelFor(indexPath: indexPath),
              let taskId = taskModel.id,
              let taskCDModel = taskCDManager.getTaskBy(id: taskId) else { return }

        let newValue = !taskModel.isCompleted
        taskCDManager.updateField(isCompleted: newValue, task: taskCDModel)

        updateTasksArrayForUpdateIsCompleted(
            taskModel: taskModel,
            currentIndexPath: indexPath,
            isCompletedNew: newValue,
            performDeadline: 0.15,
            withAnimate: true
        )
    }

    func didTapDeleteButtonInCellWith(indexPath: IndexPath) {
        guard let taskModel = getTaskModelFor(indexPath: indexPath) else { return }
        view?.showAlertDeleteTaskWith(indexPath: indexPath, title: taskModel.title)
    }

    func didTapConfirmDeleteTaskWith(indexPath: IndexPath) {
        guard let taskModel = getTaskModelFor(indexPath: indexPath),
              let taskId = taskModel.id,
              let cdTask = taskCDManager.getTaskBy(id: taskId) else { return }

        taskCDManager.delete(tasks: [cdTask])
        removeTaskWith(indexPath: indexPath)
        view?.removeTableCellWith(indexPath: indexPath)
    }

    func createTaskWith(title: String) {
        let cdTask = taskCDManager.createWith(title: title)
        let taskModel = TaskModel(cdTask: cdTask)

        let newIndex = 0
        tasks[TaskSectionKey.todo.rawValue]?.insert(taskModel, at: newIndex)
        view?.addTableCellTo(indexPath: IndexPath(item: newIndex, section: 0))
    }

    func didSelectTaskWith(indexPath: IndexPath) {
        guard let taskModel = getTaskModelFor(indexPath: indexPath),
              let taskId = taskModel.id else { return }

        selectedTaskIndexPath = indexPath

        view?.openTaskDetailWith(taskId: taskId)
    }
}

// MARK: - TasksListPresenter

extension TasksListPresenter: TaskDetailModuleOutput {
    func taskDetailModuleDidClose(taskId: UUID) {
        guard let selectedTaskIndexPath,
              let selectedTaskModel = getTaskModelFor(indexPath: selectedTaskIndexPath),
              selectedTaskModel.id == taskId,
              let actualCdTaskModel = taskCDManager.getTaskBy(id: taskId) else { return }

        selectedTaskModel.title = actualCdTaskModel.title ?? "No title"
        selectedTaskModel.description = actualCdTaskModel.descriptionText

        view?.reloadTableCellWith(indexPath: selectedTaskIndexPath)

        if selectedTaskModel.isCompleted != actualCdTaskModel.isCompleted {
            updateTasksArrayForUpdateIsCompleted(
                taskModel: selectedTaskModel,
                currentIndexPath: selectedTaskIndexPath,
                isCompletedNew: actualCdTaskModel.isCompleted,
                performDeadline: 0,
                withAnimate: false
            )
        }

        self.selectedTaskIndexPath = nil
    }

}

// MARK: - Helpers methods

private extension TasksListPresenter {
    func getTaskSectionIndexFor(indexPath: IndexPath) -> TaskSectionKey? {
        return getTaskSectionKeyFor(sectionIndex: indexPath.section)
    }

    func getTaskSectionKeyFor(sectionIndex: Int) -> TaskSectionKey? {
        return TaskSectionKey(sectionIndex: sectionIndex)
    }

    func getTaskModelFor(indexPath: IndexPath) -> TaskModel? {
        guard let taskSection = getTaskSectionIndexFor(indexPath: indexPath) else { return nil }
        return tasks[taskSection.rawValue]?[safe: indexPath.row]
    }

    func removeTaskWith(indexPath: IndexPath) {
        guard let taskSection = getTaskSectionIndexFor(indexPath: indexPath) else { return }
        tasks[taskSection.rawValue]?.remove(at: indexPath.row)
    }

    func buildTaskCellDtoFrom(taskModel: TaskModel) -> TaskCellDto {
        return TaskCellDto(
            title: taskModel.title,
            isCompleted: taskModel.isCompleted
        )
    }

    func loadTasksFromDB() {
        tasks = [
            TaskSectionKey.todo.rawValue : [],
            TaskSectionKey.completed.rawValue: [],
        ]
        let cdTodoTasks = taskCDManager.getTasksWithSorting(isCompleted: false)
        for cdTask in cdTodoTasks {
            let taskModel = TaskModel(cdTask: cdTask)
            tasks[TaskSectionKey.todo.rawValue]?.append(taskModel)
        }

        let cdCompletedTasks = taskCDManager.getTasksWithSorting(isCompleted: true)
        for cdTask in cdCompletedTasks {
            let taskModel = TaskModel(cdTask: cdTask)
            tasks[TaskSectionKey.completed.rawValue]?.append(taskModel)
        }
    }

    func updateTasksArrayForUpdateIsCompleted(
        taskModel: TaskModel,
        currentIndexPath: IndexPath,
        isCompletedNew: Bool,
        performDeadline: TimeInterval,
        withAnimate: Bool
    ) {
        guard let oldSectionKey = getTaskSectionIndexFor(indexPath: currentIndexPath) else { return }

        let newSectionKey: TaskSectionKey = isCompletedNew ? .completed : .todo
        let newTaskIndex = 0

        taskModel.isCompleted = isCompletedNew
        view?.reloadTableCellWith(indexPath: currentIndexPath)

        tasks[oldSectionKey.rawValue]?.remove(at: currentIndexPath.row)
        tasks[newSectionKey.rawValue]?.insert(taskModel, at: newTaskIndex)

        DispatchQueue.main.asyncAfter(deadline: .now() + performDeadline, execute: .init(block: { [view] in
            view?.moveTableCell(
                fromIndexPath: currentIndexPath,
                toIndexPath: IndexPath(row: newTaskIndex, section: newSectionKey.tableSectionIndex),
                withAnimate: withAnimate
            )
        }))
    }
}

// MARK: - TasksListPresenter.TaskSection

private extension TasksListPresenter {
    enum TaskSectionKey: String {
        case todo
        case completed

        init?(sectionIndex: Int) {
            switch sectionIndex {
            case 0: self.init(rawValue: Self.todo.rawValue)
            case 1: self.init(rawValue: Self.completed.rawValue)
            default: return nil
            }
        }

        var tableSectionIndex: Int {
            switch self {
            case .todo: return 0
            case .completed: return 1
            }
        }
    }
}
