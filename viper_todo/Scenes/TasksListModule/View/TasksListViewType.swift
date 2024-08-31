
import Foundation

protocol TasksListViewType: AnyObject  {
    func tableBeginUpdates()
    func tableEndUpdates()

    func refillTableCellWith(taskCellDto: TaskListCellDto, indexPath: IndexPath)
    func reloadTableCellWith(indexPath: IndexPath)

    func reloadTableData()

    func removeTableCellWith(indexPath: IndexPath)
    func moveTableCell(fromIndexPath: IndexPath, toIndexPath: IndexPath, withAnimate: Bool)
    func addTableCellTo(indexPath: IndexPath)

    func openTaskDetailWith(taskId: UUID)

    func showAlertDeleteTaskWith(indexPath: IndexPath, title: String)
}
