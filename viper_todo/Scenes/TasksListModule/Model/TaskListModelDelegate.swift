
import Foundation

protocol TaskListModelDelegate: AnyObject {
    func taskListModelBeginUpdates()
    
    func taskListModelDidCreate(indexPath: IndexPath)
    func taskListModelDidUpdate(in indexPath: IndexPath, taskModel: TaskModel)
    func taskListModelDidMove(fromIndexPath: IndexPath, toIndexPath: IndexPath, taskModel: TaskModel)
    func taskListModelDidDelete(indexPath: IndexPath)

    func taskListModelEndUpdates()
}
