
import Foundation

final class InitialDataLoader {

    private let taskNetworkManager: TasksNetworkManager
    private let taskCDManager: TaskCoreDataManager

    // MARK: - Init
    
    init(
        networkManager: TasksNetworkManager = .shared,
        taskCDManager: TaskCoreDataManager = .init()
    ) {
        self.taskNetworkManager = networkManager
        self.taskCDManager = taskCDManager
    }

    // MARK: -

    func loadData(
        successCompletionHandler: @escaping () -> Void,
        errorCompletionHandler: @escaping () -> Void
    ) {
        var page: Int = 1
        let itemsPerPage = 30
        var loadingFlag = true

        loadTasksFromPage(page, itemsPerPage: itemsPerPage) { [weak self] response in
            DispatchQueue.main.async {
                self?.createTasksFrom(response: response)

                let tasksRecieved = response.skip + itemsPerPage * page
                if tasksRecieved < response.total {
                    page += 1

                    successCompletionHandler() // надо запустить получение следующей страницы
                } else {
                    successCompletionHandler()
                }
            }
        } errorCompletion: { error in
            DispatchQueue.main.async {
                errorCompletionHandler()
            }
        }

    }

    // MARK: -

    private func loadTasksFromPage(
        _ page: Int,
        itemsPerPage: Int,
        successCompletion: @escaping (ADTasksResponse) -> Void,
        errorCompletion: @escaping (NetworkError) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [taskNetworkManager] in
            taskNetworkManager.getTasks(page: page, itemsPerPage: itemsPerPage) { result in
                switch result {
                case .success(let tasksResponse):
                    successCompletion(tasksResponse)
                case .failure(let error):
                    errorCompletion(error)
                }
            }
        }
    }

    private func createTasksFrom(response: ADTasksResponse) {
        for task in response.tasks {
            taskCDManager.createWith(
                title: task.title,
                isCompleted: task.isCompleted
            )
        }
    }
}
