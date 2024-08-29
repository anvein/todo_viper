
import Foundation

final class TasksNetworkManager: BaseNetworkManager {

    static var shared: TasksNetworkManager = .init()

    // MARK: - Tasks

    func getTasks(
        page: Int = 1,
        itemsPerPage: Int = 30, 
        completion: @escaping (Result<ADTasksResponse, NetworkError>) -> Void
    ) {
        let route = ADRoute.tasksList(page: page, itemsPerPage: itemsPerPage)
        getData(route: route, completion: completion) 
    }

}
