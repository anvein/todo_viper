
import Foundation

protocol TaskCreatePanelDelegate: AnyObject {
    func taskCreatePanelDidTapCreateButton(title: String)
    func taskCreatePanelDidChangedState(newState: TaskCreatePanel.State)
}
