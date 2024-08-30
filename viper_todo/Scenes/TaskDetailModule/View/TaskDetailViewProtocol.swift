
import Foundation

protocol TaskDetailViewProtocol: AnyObject {
    func setTaskData(task: TaskDetailDto)
    func setTaskIsCompleted(_ isCompleted: Bool)
    func setTaskTitle(_ title: String)
    func setTaskDescription(_ text: String)
}
