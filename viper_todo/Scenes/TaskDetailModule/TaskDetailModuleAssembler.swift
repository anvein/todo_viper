
import Foundation

final class TaskDetailModuleAssembler {
    func assembly(
        taskId: UUID,
        moduleOutput: TaskDetailModuleOutput
    ) -> TaskDetailViewController {
        let taskCDService = TaskCoreDataService()

        let model = TaskDetailModel(taskId: taskId, taskCDService: taskCDService)
        let presenter = TaskDetailPresenter(model: model)

        let viewController = TaskDetailViewController(presenter: presenter)
        presenter.setView(viewController)
        presenter.setModuleOutput(moduleOutput)
        return viewController
    }
}
