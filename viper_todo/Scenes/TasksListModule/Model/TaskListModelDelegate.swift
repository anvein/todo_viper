
import Foundation

protocol TaskListModelDelegate: AnyObject {
    func taskListModelBeginUpdates()
    
    func taskListModelTaskDidCreate(indexPath: IndexPath)
    func taskListModelTaskDidUpdate(in indexPath: IndexPath, taskModel: TaskModel)
    func taskListModelTaskDidMove(fromIndexPath: IndexPath, toIndexPath: IndexPath, taskModel: TaskModel)
    func taskListModelTaskDidDelete(indexPath: IndexPath)

    func taskListModelSectionDidInsert(sectionIndex: Int)
    func taskListModelSectionDidDelete(sectionIndex: Int)

    func taskListModelEndUpdates()
}
