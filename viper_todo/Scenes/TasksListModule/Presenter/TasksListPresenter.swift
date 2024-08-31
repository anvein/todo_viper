
import Foundation

final class TasksListPresenter {

    // MARK: - Services

    private let defaultsManager: UserDefaultsService
    private let taskCDManager: TaskCoreDataService
    private let initialDataLoader: InitialDataLoader

    // MARK: - View

    private weak var view: TasksListViewType?

    // MARK: - Model

    private var model: TaskListModel
    private var selectedTaskIndexPath: IndexPath?

    // MARK: - Init

    init(
        model: TaskListModel,
        defaultsManager: UserDefaultsService = .shared,
        taskCDManager: TaskCoreDataService = .init(),
        initialDataLoader: InitialDataLoader = .init()
    ) {
        self.model = model
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
                // скрыть лоадер
            } errorCompletionHandler: {
                
            }
        } else {

        }
    }

    func getSectionsCount() -> Int {
        return model.getSectionsCount()
    }

    func getTasksCountIn(sectionIndex: Int) -> Int {
        return model.getTasksCountIn(in: sectionIndex)
    }

    func getTaskCellFor(indexPath: IndexPath) -> TaskListCellDto? {
        let taskModel = model.getTask(for: indexPath)
        return buildTaskCellDtoFrom(taskModel: taskModel)
    }

    func didTapIsDoneButtonInCellWith(indexPath: IndexPath) {
        model.switchAndUpdateTaskIsCompletedFieldWith(indexPath: indexPath)
    }

    func didTapDeleteButtonInCellWith(indexPath: IndexPath) {
        let taskModel = model.getTask(for: indexPath)
        view?.showAlertDeleteTaskWith(indexPath: indexPath, title: taskModel.title)
    }

    func didTapConfirmDeleteTaskWith(indexPath: IndexPath) {
        model.deleteTaskWith(indexPath: indexPath)
    }

    func createTaskWith(title: String) {
        model.createTaskWith(title: title)
    }

    func didSelectTaskWith(indexPath: IndexPath) {
        guard let taskId = model.getTaskIdFor(indexPath: indexPath) else { return }
        
        selectedTaskIndexPath = indexPath
        view?.openTaskDetailWith(taskId: taskId)
    }
}

extension TasksListPresenter: TaskListModelDelegate {

    func taskListModelBeginUpdates() {
        view?.tableBeginUpdates()
    }

    func taskListModelDidCreate(indexPath: IndexPath) {
        view?.addTableCellTo(indexPath: indexPath)
    }

    func taskListModelDidUpdate(in indexPath: IndexPath, taskModel: TaskModel) {
        let taskCellDto = buildTaskCellDtoFrom(taskModel: taskModel)
        view?.refillTableCellWith(taskCellDto: taskCellDto, indexPath: indexPath)
    }

    func taskListModelDidMove(fromIndexPath: IndexPath, toIndexPath: IndexPath, taskModel: TaskModel) {
        let taskCellDto = self.buildTaskCellDtoFrom(taskModel: taskModel)
        view?.refillTableCellWith(taskCellDto: taskCellDto, indexPath: fromIndexPath)
        view?.moveTableCell(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath, withAnimate: true)

        if selectedTaskIndexPath != nil && selectedTaskIndexPath == fromIndexPath {
            selectedTaskIndexPath = toIndexPath
        }
    }

    func taskListModelDidDelete(indexPath: IndexPath) {
        view?.removeTableCellWith(indexPath: indexPath)
    }

    func taskListModelEndUpdates() {
        view?.tableEndUpdates()
    }
}

// MARK: - TaskDetailModuleOutput

extension TasksListPresenter: TaskDetailModuleOutput {
    func taskDetailModuleDidClose(taskId: UUID) {
        self.selectedTaskIndexPath = nil
    }

}

// MARK: - Helpers methods

private extension TasksListPresenter {
    func buildTaskCellDtoFrom(taskModel: TaskModel) -> TaskListCellDto {
        return TaskListCellDto(
            title: taskModel.title,
            isCompleted: taskModel.isCompleted
        )
    }
}
