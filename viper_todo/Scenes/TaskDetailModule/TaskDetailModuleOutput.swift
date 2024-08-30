
import Foundation

protocol TaskDetailModuleOutput: AnyObject {
    func taskDetailModuleDidClose(taskId: UUID)
}
