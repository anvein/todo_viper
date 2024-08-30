
import UIKit
import SnapKit

final class TaskListMainView: UIView {

    // MARK: - Setup properties

    var tasksTableDelegate: UITableViewDelegate? {
        get { tasksTableView.delegate }
        set { tasksTableView.delegate = newValue }
    }

    var tasksTableDataSource: UITableViewDataSource? {
        get { tasksTableView.dataSource }
        set { tasksTableView.dataSource = newValue }
    }

    var taskCreatePanelDelegate: TaskCreatePanelDelegate? {
        get { taskCreatePanel.delegate }
        set { taskCreatePanel.delegate = newValue }
    }

    // MARK: - Subviews

    private let bgImageView: UIImageView = {
        $0.image = UIImage(named: "listBackground")
        $0.contentMode = .scaleAspectFill
        $0.layer.zPosition = 0
        return $0
    }(UIImageView())

    lazy var tasksTableView: UITableView = {
        $0.backgroundColor = nil
        $0.scrollsToTop = true
        $0.separatorStyle = .none
        $0.estimatedRowHeight = 60
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = false
        $0.contentInset.bottom = 80
        $0.layer.zPosition = 1

        $0.tableHeaderView = buildTasksTableHeaderView()

        $0.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.className)
        return $0
    }(UITableView())

    private let taskCreatePanel: TaskCreatePanel = {
        $0.textFieldPlaceholder = "Создать задачу"
        $0.layer.zPosition = 2
        return $0
    }(TaskCreatePanel())

    // MARK: - Constraints

    private var panelHeightConstraint: Constraint?
    private var panelTopPaddingConstraint: Constraint?
    private var panelHorizontalPaddingsConstraint: Constraint?


    // MARK: - Setup (internal)

    func setupLayout() {
        backgroundColor = .tasksListBackground

        addSubviews(tasksTableView, bgImageView, taskCreatePanel)

        bgImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        tasksTableView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(8)
        }

        let panelState = taskCreatePanel.currentState
        taskCreatePanel.snp.makeConstraints {
            $0.bottom.equalTo(keyboardLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            panelHeightConstraint = $0.height.equalTo(panelState.panelHeight).constraint
            panelTopPaddingConstraint = $0.top.equalTo(tasksTableView.snp.bottom).offset(panelState.panelSidesPadding).constraint
            panelHorizontalPaddingsConstraint = $0.horizontalEdges.equalToSuperview().inset(panelState.panelSidesPadding).constraint
        }
    }

    // MARK: - Update view

    func setTableHeaderVisible(_ visible: Bool) {
        guard let tableHeader = tasksTableView.tableHeaderView else { return }

        UIView.transition(
            with: tableHeader,
            duration: visible ? 0.2 : 0.1,
            options: [.transitionCrossDissolve]
        ) { [tableHeader] in
            tableHeader.alpha = visible ? 1 : 0
        }
    }

    func updatePanelForState(_ newState: TaskCreatePanel.State) {
        panelHeightConstraint?.update(offset: newState.panelHeight)
        panelTopPaddingConstraint?.update(offset: newState.panelSidesPadding)
        panelHorizontalPaddingsConstraint?.update(inset: newState.panelSidesPadding)

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}

private extension TaskListMainView {

    // MARK: - Setup (private)

    func buildTasksTableHeaderView() -> UILabel {
        let headerLabel = UILabel()
        headerLabel.text = "📅 Задачи"
        headerLabel.textColor = .white
        headerLabel.font = .systemFont(ofSize: 32, weight: .bold)
        headerLabel.sizeToFit()
        headerLabel.frame = .init(
            origin: .zero,
            size: .init(
                width: headerLabel.frame.width,
                height: headerLabel.frame.height + 10
            )
        )

        return headerLabel
    }
}

