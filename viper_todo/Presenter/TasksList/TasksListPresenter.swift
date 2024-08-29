
import Foundation

final class TasksListPresenter {

    // MARK: - Services

    private let defaultsManager: UserDefaultsManager
    private let taskCDManager: TaskCoreDataManager
    private let initialDataLoader: InitialDataLoader

    // MARK: - View

    weak var view: TasksListViewType?

    // MARK: - Model

    private var tasks: [TaskSectionKey.RawValue: [TaskModel]] = [:]

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
//            view?.reloadTableData()
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
              let oldSection = getTaskSectionIndexFor(indexPath: indexPath),
              let taskCDModel = taskCDManager.getTaskBy(id: taskId) else { return }

        let newValue = !taskModel.isCompleted
        let newSection: TaskSectionKey = newValue ? .completed : .todo
        let newTaskIndex = 0

        taskCDManager.updateField(isCompleted: newValue, task: taskCDModel)

        taskModel.isCompleted = newValue
        view?.reloadTableCellWith(indexPath: indexPath)

        tasks[oldSection.rawValue]?.remove(at: indexPath.row)
        tasks[newSection.rawValue]?.insert(taskModel, at: newTaskIndex)
//        view?.reloadTableData()
        view?.moveTableCell(
            fromIndexPath: indexPath,
            toIndexPath: IndexPath(row: newTaskIndex, section: newSection.tableSectionIndex)
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
        let taskModel = buildTaskModelFrom(cdTask: cdTask)

        let newIndex = 0
        tasks[TaskSectionKey.todo.rawValue]?.insert(taskModel, at: newIndex)
        view?.addTableCellTo(indexPath: IndexPath(item: newIndex, section: 0))
    }

    func didSelectTaskWith(indexPath: IndexPath) {
        guard let taskModel = getTaskModelFor(indexPath: indexPath),
              let taskId = taskModel.id,
              let cdTask = taskCDManager.getTaskBy(id: taskId) else { return }


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

    func buildTaskModelFrom(cdTask: CDTask) -> TaskModel {
        return TaskModel(
            id: cdTask.id?.uuidString,
            title: cdTask.title ?? "",
            description: cdTask.descriptionText,
            isCompleted: cdTask.isCompleted,
            createdAt: cdTask.createdAt
        )
    }

    func loadTasksFromDB() {
        tasks = [
            TaskSectionKey.todo.rawValue : [],
            TaskSectionKey.completed.rawValue: [],
        ]
        let cdTodoTasks = taskCDManager.getTasksWithSorting(isCompleted: false)
        for cdTask in cdTodoTasks {
            let taskModel = buildTaskModelFrom(cdTask: cdTask)
            tasks[TaskSectionKey.todo.rawValue]?.append(taskModel)
        }

        let cdCompletedTasks = taskCDManager.getTasksWithSorting(isCompleted: true)
        for cdTask in cdCompletedTasks {
            let taskModel = buildTaskModelFrom(cdTask: cdTask)
            tasks[TaskSectionKey.completed.rawValue]?.append(taskModel)
        }
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
