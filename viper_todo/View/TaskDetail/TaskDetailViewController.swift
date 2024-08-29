import UIKit
import SnapKit

final class TaskDetailViewController: UIViewController {

    // MARK: - Settings

    private static let isDoneButtonSize: CGFloat = 24

    // MARK: - Subviews

    private lazy var isDoneButton: SwitchableButton = {
        let checkmarkConfig = UIImage.SymbolConfiguration(pointSize: 0, weight: .heavy, scale: .medium)
        let checkmarkImage = UIImage(systemName: "checkmark", withConfiguration: checkmarkConfig)?
            .withTintColor(.white)

        var configForIsOn = UIButton.Configuration.filled()
        configForIsOn.background.backgroundColor = .isDoneButtonCompletedBg
        configForIsOn.background.cornerRadius = TaskDetailViewController.isDoneButtonSize / 2
        configForIsOn.image = checkmarkImage
        configForIsOn.cornerStyle = .fixed
        $0.configurationForIsOn = configForIsOn

        var configForIsOff = UIButton.Configuration.filled()
        configForIsOff.background.backgroundColor = .clear
        configForIsOff.background.strokeWidth = 2
        configForIsOff.background.strokeColor = .isDoneButtonBorder
        configForIsOff.background.cornerRadius = TaskDetailViewController.isDoneButtonSize / 2
        configForIsOff.cornerStyle = .fixed
        $0.configurationForIsOff = configForIsOff

        $0.tintAdjustmentMode = .normal
//        $0.delegate = self

        return $0
    }(SwitchableButton())

    private lazy var taskTitleTextView: UITextView = {
        $0.isScrollEnabled = false
        $0.returnKeyType = .done
        $0.backgroundColor = .white
        $0.textColor = .textBlack
        $0.font = .systemFont(ofSize: 22, weight: .medium)
        return $0
    }(UITextView())

    

}

private extension TaskDetailViewController {
    func setupLayout() {
        view.addSubviews(isDoneButton, taskTitleTextView)

        isDoneButton.snp.makeConstraints {
            $0.top.equalTo(taskTitleTextView.snp.top).offset(9)
            $0.leading.equalToSuperview().inset(16)
        }

        taskTitleTextView.snp.makeConstraints {
            $0.leading.equalTo(isDoneButton.snp.trailing).offset(14)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().inset(16)
        }

    }
}
