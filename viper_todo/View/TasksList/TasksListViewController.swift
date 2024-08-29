
import UIKit
import SnapKit


final class TasksListViewController: UIViewController {

    // MARK: - Subviews

    private lazy var bgImageView: UIImageView = {
        $0.image = UIImage(named: "listBackground")
        $0.contentMode = .scaleAspectFill
        $0.layer.zPosition = 0
        return $0
    }(UIImageView())

    private lazy var tasksTableView: UITableView = {
        $0.backgroundColor = nil
        $0.scrollsToTop = true
        $0.separatorStyle = .none
        $0.estimatedRowHeight = 60
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = false
        $0.contentInset.bottom = 80
        $0.layer.zPosition = 1

        let headerLabel = UILabel()
        headerLabel.text = self.title
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
        $0.tableHeaderView = headerLabel

        $0.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.className)
        $0.dataSource = self
        $0.delegate = self
        return $0
    }(UITableView())
    
    private lazy var taskCreatePanel: TaskCreatePanel = {
        $0.textFieldPlaceholder = "Создать задачу"
        $0.delegate = self
        $0.layer.zPosition = 2
        return $0
    }(TaskCreatePanel())

    // MARK: - Constraints

    private var panelTopPaddingConstraint: Constraint?
    private var panelHorizontalPaddingsConstraint: Constraint?

    // MARK: - State

    private var isShowNavigationTitle: Bool = true {
        willSet {
            guard isShowNavigationTitle != newValue else { return }
            setNavigationTitleVisible(newValue)
            setTableHeaderVisible(!newValue)
        }
    }

    // MARK: - Presenter

    private var presenter: TasksListPresenterType

    // MARK: - Init

    init(presenter: TasksListPresenterType) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "📅 Задачи"
        presenter.viewDidLoad()
        setupSubviews()


        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = .white
            navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.clear,
            ]

            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = true
            navigationBar.backgroundColor = .clear
        }
    }
}

extension TasksListViewController {
    // MARK: - Setup

    func setupSubviews() {
        view.backgroundColor = .tasksListBackground

        view.addSubviews(tasksTableView, bgImageView, taskCreatePanel)

        bgImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        tasksTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(8)
        }

        let panelSidesPadding = taskCreatePanel.currentState.panelSidesPadding
        taskCreatePanel.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            panelTopPaddingConstraint = $0.top.equalTo(tasksTableView.snp.bottom).offset(panelSidesPadding).constraint
            panelHorizontalPaddingsConstraint = $0.horizontalEdges.equalToSuperview().inset(panelSidesPadding).constraint
        }
    }

    // MARK: - Update view

    func setNavigationTitleVisible(_ visible: Bool) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let titleColor: UIColor = visible ? .white : .clear

        UIView.transition(
            with: navigationBar,
            duration: 0.15,
            options: [.transitionCrossDissolve]
        ) { [navigationBar] in
            navigationBar.titleTextAttributes = [.foregroundColor: titleColor]
        }
    }

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
}

extension TasksListViewController: TasksListViewType {
    
    func reloadTableData() {
        tasksTableView.reloadData()
    }

    func reloadTableCellWith(indexPath: IndexPath) {
        tasksTableView.reloadRows(at: [indexPath], with: .none)
    }

    func addTableCellTo(indexPath: IndexPath) {
        tasksTableView.insertRows(at: [indexPath], with: .fade)
    }

    func removeTableCellWith(indexPath: IndexPath) {
        tasksTableView.deleteRows(at: [indexPath], with: .fade)
    }

    func moveTableCell(fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        tasksTableView.moveRow(at: fromIndexPath, to: toIndexPath)
    }

    func showAlertDeleteTaskWith(indexPath: IndexPath, title: String) {
        let alert = UIAlertController(
            title: "Задача \"\(title)\" будет удалена без возможности восстановления",
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(.init(title: "Удалить", style: .destructive) { [presenter] _ in
            presenter.didTapConfirmDeleteTaskWith(indexPath: indexPath)
        })
        alert.addAction(.init(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TasksListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.getSectionsCount()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getTasksCountIn(sectionIndex: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.className, for: indexPath)
        let taskCellDto = presenter.getTaskCellFor(indexPath: indexPath)

        if let cell = cell as? TaskTableViewCell, let taskCellDto {
            cell.fillFrom(cellDto: taskCellDto)
            cell.delegate = self
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TasksListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: вызов в presenter + в фабрику
        
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // TODO: в фабрику
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [presenter] _, _, completionHandler in
            presenter.didTapDeleteButtonInCellWith(indexPath: indexPath)

            completionHandler(false)
        }

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HighlightableCell
        cell?.setCellHighlighted(true)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HighlightableCell
        cell?.setCellHighlighted(false)
    }
}

extension TasksListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y

        let headerHeight = (tasksTableView.tableHeaderView?.bounds.height ?? 0) / 3

        if offset >= headerHeight && !isShowNavigationTitle {
            isShowNavigationTitle = true
        } else if offset < headerHeight && isShowNavigationTitle {
            isShowNavigationTitle = false
        }
    }
}

// MARK: - TaskTableViewCellDelegate

extension TasksListViewController: TaskTableViewCellDelegate {
    func taskTableViewCellDidTapIsDoneButton(indexPath: IndexPath) {
        presenter.didTapIsDoneButtonInCellWith(indexPath: indexPath)
    }
}

// MARK: - CreateTaskBottomPanelDelegate

extension TasksListViewController: CreateTaskPanelDelegate {
    func createTaskPanelDidTapCreateButton(title: String) {
        let title = title.trimmingCharacters(in: .whitespaces)
        if !title.isEmpty {
            presenter.createTaskWith(title: title)
        }
    }
    
    func createTaskPanelDidChangedState(newState: TaskCreatePanel.State) {
        panelTopPaddingConstraint?.update(offset: newState.panelSidesPadding)
        panelHorizontalPaddingsConstraint?.update(inset: newState.panelSidesPadding)

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

}
