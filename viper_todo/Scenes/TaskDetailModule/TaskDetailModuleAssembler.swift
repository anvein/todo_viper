
import Foundation

final class TaskDetailModuleAssembler {
    func assembly(
        taskId: UUID,
        moduleOutput: TaskDetailModuleOutput
    ) -> TaskDetailViewController {
        let presenter = TaskDetailPresenter(taskId: taskId)
        let viewController = TaskDetailViewController(presenter: presenter)
        presenter.setView(viewController)
        presenter.setModuleOutput(moduleOutput)
        return viewController
    }
}
