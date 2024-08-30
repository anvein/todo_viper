
import Foundation

protocol TasksListViewType: AnyObject  {
    func reloadTableData()
    func reloadTableCellWith(indexPath: IndexPath)
    func removeTableCellWith(indexPath: IndexPath)
    func moveTableCell(fromIndexPath: IndexPath, toIndexPath: IndexPath)
    func addTableCellTo(indexPath: IndexPath)

    func showAlertDeleteTaskWith(indexPath: IndexPath, title: String)
}
