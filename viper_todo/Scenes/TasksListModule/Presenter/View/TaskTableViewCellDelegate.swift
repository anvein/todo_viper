
import Foundation

protocol TaskTableViewCellDelegate: AnyObject {
    func taskTableViewCellDidTapIsDoneButton(indexPath: IndexPath)
}
