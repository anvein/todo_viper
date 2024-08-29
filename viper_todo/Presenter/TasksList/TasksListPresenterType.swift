
import Foundation

protocol TasksListPresenterType {
    func viewDidLoad()

    func getSectionsCount() -> Int
    func getTasksCountIn(sectionIndex: Int) -> Int

    func getTaskCellFor(indexPath: IndexPath) -> TaskCellDto?

    func didTapIsDoneButtonInCellWith(indexPath: IndexPath)

    func didTapDeleteButtonInCellWith(indexPath: IndexPath)
    func didTapConfirmDeleteTaskWith(indexPath: IndexPath)

    func createTaskWith(title: String)

    func didSelectTaskWith(indexPath: IndexPath)
}
