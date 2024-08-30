
import Foundation

protocol TasksListViewType: AnyObject  {
    func reloadTableData()
    func reloadTableCellWith(indexPath: IndexPath)
    func removeTableCellWith(indexPath: IndexPath)
    func moveTableCell(fromIndexPath: IndexPath, toIndexPath: IndexPath, withAnimate: Bool)
    func addTableCellTo(indexPath: IndexPath)

    func openTaskDetailWith(taskId: UUID)

    func showAlertDeleteTaskWith(indexPath: IndexPath, title: String)
}
