
import Foundation

final class TaskListModuleAssemler {
    func assembly() -> TasksListViewController {
        let tasksListPresenter = TasksListPresenter()
        let assembler = TaskDetailModuleAssembler()
        let taskListVC = TasksListViewController(
            presenter: tasksListPresenter,
            taskDetailAssembler: assembler
        )
        tasksListPresenter.setView(taskListVC)

        return taskListVC
    }
}
