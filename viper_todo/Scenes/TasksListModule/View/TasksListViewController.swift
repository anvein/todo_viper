
import UIKit
import SnapKit


final class TasksListViewController: UIViewController {

    private var presenter: TasksListPresenterType
    private let taskDetailModuleAssembler: TaskDetailModuleAssembler

    // MARK: - Subviews

    private lazy var mainView: TaskListMainView = .init()

    // MARK: - State

    private var isShowNavigationTitle: Bool = true {
        willSet {
            guard isShowNavigationTitle != newValue else { return }
            setNavigationTitleVisible(newValue)
            mainView.setTableHeaderVisible(!newValue)
        }
    }

    // MARK: - Init

    init(
        presenter: TasksListPresenterType,
        taskDetailAssembler: TaskDetailModuleAssembler
    ) {
        self.presenter = presenter
        self.taskDetailModuleAssembler = taskDetailAssembler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "📅 Задачи"

        presenter.viewDidLoad()
        mainView.setupLayout()
        setupDelegates()
        setupNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainView.endEditing(true)
    }

}

extension TasksListViewController {
    // MARK: - Setup

    func setupDelegates() {
        mainView.tasksTableDataSource = self
        mainView.tasksTableDelegate = self
        mainView.taskCreatePanelDelegate = self
    }

    func setupNavigationBar() {
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
}

extension TasksListViewController: TasksListViewType {

    func tableBeginUpdates() {
        mainView.tasksTableView.beginUpdates()
    }
    
    func tableEndUpdates() {
        mainView.tasksTableView.endUpdates()
    }
    
    func refillTableCellWith(taskCellDto: TaskListCellDto, indexPath: IndexPath) {
        let cell = mainView.tasksTableView.cellForRow(at: indexPath) as? TaskTableViewCell
        cell?.fillFrom(cellDto: taskCellDto)
    }

    func reloadTableData() {
        mainView.tasksTableView.reloadData()
    }

    func reloadTableCellWith(indexPath: IndexPath) {
        mainView.tasksTableView.reloadRows(at: [indexPath], with: .none)
    }

    func addTableCellTo(indexPath: IndexPath) {
        mainView.tasksTableView.insertRows(at: [indexPath], with: .fade)
    }

    func removeTableCellWith(indexPath: IndexPath) {
        mainView.tasksTableView.deleteRows(at: [indexPath], with: .fade)
    }

    func moveTableCell(fromIndexPath: IndexPath, toIndexPath: IndexPath, withAnimate: Bool) {
        if withAnimate {
            mainView.tasksTableView.moveRow(at: fromIndexPath, to: toIndexPath)
        } else {
            UIView.performWithoutAnimation { [mainView] in
                mainView.tasksTableView.moveRow(at: fromIndexPath, to: toIndexPath)
            }
        }
    }

    func addTableSectionWith(index: Int) {
        mainView.tasksTableView.insertSections([index], with: .automatic)
    }

    func deleteTableSectionWith(index: Int) {
        mainView.tasksTableView.deleteSections([index], with: .automatic)
    }

    func openTaskDetailWith(taskId: UUID) {
        guard let navigationController,
              let parentPresenter = presenter as? TaskDetailModuleOutput else { return }
        
        let taskDetailVC = taskDetailModuleAssembler.assembly(
            taskId: taskId,
            moduleOutput: parentPresenter
        )
        navigationController.pushViewController(taskDetailVC, animated: true)
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
        presenter.didSelectTaskWith(indexPath: indexPath)
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

        let headerHeight = (mainView.tasksTableView.tableHeaderView?.bounds.height ?? 0) / 3

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

extension TasksListViewController: TaskCreatePanelDelegate {
    func taskCreatePanelDidTapCreateButton(title: String) {
        let title = title.trimmingCharacters(in: .whitespaces)
        if !title.isEmpty {
            presenter.createTaskWith(title: title)
        }
    }
    
    func taskCreatePanelDidChangedState(newState: TaskCreatePanel.State) {
        mainView.updatePanelForState(newState)
    }

}
