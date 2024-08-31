
import Foundation

final class TaskListModuleAssemler {
    func assembly() -> TasksListViewController {
        let taskCDManager = TaskCoreDataService()
        let model = TaskListModel(taskCDManager: taskCDManager)

        let presenter = TasksListPresenter(model: model)
        model.delegate = presenter

        let assembler = TaskDetailModuleAssembler()
        let taskListVC = TasksListViewController(
            presenter: presenter,
            taskDetailAssembler: assembler
        )
        presenter.setView(taskListVC)

        return taskListVC
    }
}
