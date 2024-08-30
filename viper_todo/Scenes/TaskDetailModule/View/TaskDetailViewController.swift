import UIKit
import SnapKit

final class TaskDetailViewController: UIViewController {

    // MARK: - Presenter

    private let presenter: TaskDetailPresenterProtocol

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
        $0.delegate = self

        return $0
    }(SwitchableButton())

    private lazy var taskTitleTextView: UITextView = {
        $0.isScrollEnabled = false
        $0.returnKeyType = .done
        $0.backgroundColor = .white
        $0.textColor = .textBlack
        $0.font = .systemFont(ofSize: 22, weight: .medium)
        $0.delegate = self
        return $0
    }(UITextView())

    private lazy var taskDescriptionTextView: TaskDetailDescriptionTextView = {
        $0.placeholder = "Описание задачи"
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = true
        $0.returnKeyType = .done
        $0.backgroundColor = .white
        $0.textColor = .textBlack
        $0.font = .systemFont(ofSize: 18, weight: .regular)
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        $0.externalDelegate = self
        return $0
    }(TaskDetailDescriptionTextView())

    private let createdAtLabel: UILabel = {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 1
        $0.textColor = .textGray
        $0.textAlignment = .center
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        return $0
    }(UILabel())

    // MARK: - Init

    init(presenter: TaskDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.viewDidLoad()

        setup()
        setupLayout()
        setupNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent || isBeingDismissed {
            presenter.didCloseTaskDetail()
        }
    }

}

private extension TaskDetailViewController {

    // MARK: - Setup

    func setup() {
        view.backgroundColor = .white
    }

    func setupLayout() {
        view.addSubviews(
            isDoneButton,
            taskTitleTextView,
            taskDescriptionTextView,
            createdAtLabel
        )

        isDoneButton.snp.makeConstraints {
            $0.size.equalTo(Self.isDoneButtonSize)
            $0.top.equalTo(taskTitleTextView.snp.top).offset(9)
            $0.leading.equalToSuperview().inset(16)
        }

        taskTitleTextView.snp.makeConstraints {
            $0.leading.equalTo(isDoneButton.snp.trailing).offset(14)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().inset(16)
        }

        taskDescriptionTextView.snp.makeConstraints {
            $0.top.equalTo(taskTitleTextView.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }

        createdAtLabel.snp.makeConstraints {
            $0.top.equalTo(taskDescriptionTextView.snp.bottom).offset(10)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }

    func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = .textBlack
        }
    }

    // MARK: - Update view

    func showTaskTextFieldNavigationItemReady() {
        let rightBarButonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(didTapNavigationItemReady)
        )

        navigationController?.navigationBar.topItem?.setRightBarButton(rightBarButonItem, animated: true)
    }

    // MARK: - Actions handlers

    @objc func didTapNavigationItemReady() {
        navigationItem.setRightBarButton(nil, animated: true)
        view.endEditing(true)
    }

    // MARK: - Helpers

    func setTaskCreatedAtFrom(task: TaskDetailDto) {
        if let createdAt = task.createdAt {
            createdAtLabel.text = "Создано: \(createdAt)"
        } else {
            createdAtLabel.text = nil
        }
    }
}

// MARK: - TaskDetailViewProtocol

extension TaskDetailViewController: TaskDetailViewProtocol {
    
    func setTaskData(task: TaskDetailDto) {
        isDoneButton.isOn = task.isCompleted
        taskTitleTextView.text = task.title
        taskDescriptionTextView.text = task.descriptionText
        setTaskCreatedAtFrom(task: task)
    }

    func setTaskTitle(_ title: String) {
        taskTitleTextView.text = title
    }

    func setTaskDescription(_ text: String) {
        taskDescriptionTextView.text = text
    }

    func setTaskIsCompleted(_ isCompleted: Bool) {
        isDoneButton.isOn = isCompleted
    }
}

// MARK: - SwitchableButtonDelegate

extension TaskDetailViewController: SwitchableButtonDelegate {
    func switchableButtonDidTap(button: SwitchableButton) {
        presenter.didTapIsDoneButton()
    }

}

// MARK: - UITextViewDelegate (title)

extension TaskDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView == taskTitleTextView else { return true }
        
        if (text == "\n") {
            navigationController?.navigationBar.topItem?.setRightBarButton(nil, animated: true)
            view.endEditing(true)

            return false
        } else {
            return true
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        showTaskTextFieldNavigationItemReady()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == taskTitleTextView {
            presenter.didEndEditTaskTitle(textView.text)
        } else if textView == taskDescriptionTextView {
            presenter.didEndEditTaskDescription(textView.text)
        }

    }

}
