
import Foundation

protocol CreateTaskPanelDelegate: AnyObject {
    func createTaskPanelDidTapCreateButton(title: String)
    func createTaskPanelDidChangedState(newState: TaskCreatePanel.State)
}
