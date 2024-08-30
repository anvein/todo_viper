
import Foundation

protocol TaskDetailPresenterProtocol: AnyObject {
    func viewDidLoad()

    func didTapIsDoneButton()
    func didEndEditTaskTitle(_ title: String)
    func didEndEditTaskDescription(_ text: String?)

    func didCloseTaskDetail()
}
