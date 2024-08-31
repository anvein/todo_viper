
import Foundation

final class TasksListPresenter {

    // MARK: - Services

    private let defaultsService: UserDefaultsService
    private let initialDataLoader: InitialDataLoader

    // MARK: - MVP components

    private weak var view: TasksListViewType?
    private var model: TaskListModel

    // MARK: - Init

    init(
        model: TaskListModel,
        defaultsManager: UserDefaultsService = .shared,
        initialDataLoader: InitialDataLoader = .init()
    ) {
        self.model = model
        self.defaultsService = defaultsManager
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
        if !defaultsService.getIsTasksFirstLoad() {
            // TODO: установить лоадер
            initialDataLoader.loadData() { [weak self] in
                self?.defaultsService.setIsTasksFirstLoad(true)
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
        model.updateAndSwitchIsCompletedFieldWith(indexPath: indexPath)
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
        
        model.setSelectedTaskIndexPath(indexPath)
        view?.openTaskDetailWith(taskId: taskId)
    }
}

extension TasksListPresenter: TaskListModelDelegate {

    func taskListModelBeginUpdates() {
        view?.tableBeginUpdates()
    }

    func taskListModelEndUpdates() {
        view?.tableEndUpdates()
    }

    func taskListModelTaskDidCreate(indexPath: IndexPath) {
        view?.addTableCellTo(indexPath: indexPath)
    }

    func taskListModelTaskDidUpdate(in indexPath: IndexPath, taskModel: TaskModel) {
        let taskCellDto = buildTaskCellDtoFrom(taskModel: taskModel)
        view?.refillTableCellWith(taskCellDto: taskCellDto, indexPath: indexPath)
    }

    func taskListModelTaskDidMove(fromIndexPath: IndexPath, toIndexPath: IndexPath, taskModel: TaskModel) {
        let taskCellDto = self.buildTaskCellDtoFrom(taskModel: taskModel)
        view?.refillTableCellWith(taskCellDto: taskCellDto, indexPath: fromIndexPath)
        view?.moveTableCell(fromIndexPath: fromIndexPath, toIndexPath: toIndexPath, withAnimate: true)

        if model.selectedTaskIndexPath != nil && model.selectedTaskIndexPath == fromIndexPath {
            model.setSelectedTaskIndexPath(toIndexPath)
        }
    }

    func taskListModelTaskDidDelete(indexPath: IndexPath) {
        view?.removeTableCellWith(indexPath: indexPath)
    }

    func taskListModelSectionDidInsert(sectionIndex: Int) {
        view?.addTableSectionWith(index: sectionIndex)
    }

    func taskListModelSectionDidDelete(sectionIndex: Int) {
        view?.deleteTableSectionWith(index: sectionIndex)
    }
}

// MARK: - TaskDetailModuleOutput

extension TasksListPresenter: TaskDetailModuleOutput {
    func taskDetailModuleDidClose(taskId: UUID) {
        model.setSelectedTaskIndexPath(nil)
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
