
import Foundation
import CoreData

final class TaskListModel: NSObject {
    
    // MARK: - Services

    private let taskCDManager: TaskCoreDataService
    private let coreDataStack: CoreDataStack

    weak var delegate: TaskListModelDelegate?

    // MARK: -

    private var fetchedResultsController: NSFetchedResultsController<CDTask>

    // MARK: - Init

    init(
        taskCDManager: TaskCoreDataService,
        coreDataStack: CoreDataStack = .shared
    ) {
        self.taskCDManager = taskCDManager
        self.coreDataStack = coreDataStack

        let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: "isCompleted", ascending: true),
            .init(key: "createdAt", ascending: false),
        ]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.context,
            sectionNameKeyPath: "isCompleted",
            cacheName: nil
        )

        super.init()
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            // TODO: обработать нормально
            print("Fetch failed")
        }
    }

    // MARK: - Get

    func getTaskIdFor(indexPath: IndexPath) -> UUID? {
        return getCDTask(at: indexPath).id
    }

    func getSectionsCount() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func getTasksCountIn(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func getTask(for indexPath: IndexPath) -> TaskModel {
        let cdTask = getCDTask(at: indexPath)
        return TaskModel(cdTask: cdTask)
    }

    // MARK: - Modify Task

    func switchAndUpdateTaskIsCompletedFieldWith(indexPath: IndexPath) {
        let cdTask = getCDTask(at: indexPath)
        let newValue = !cdTask.isCompleted
        taskCDManager.updateField(isCompleted: newValue, task: cdTask)
    }

    func deleteTaskWith(indexPath: IndexPath) {
        let cdTask = getCDTask(at: indexPath)
        taskCDManager.delete(tasks: cdTask)
    }

    func createTaskWith(title: String) {
        taskCDManager.createWith(title: title)
    }

}

// MARK: - Private methods

private extension TaskListModel {
    func getCDTask(at indexPath: IndexPath) -> CDTask {
        return fetchedResultsController.object(at: indexPath)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TaskListModel: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.taskListModelBeginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.taskListModelEndUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath {
                delegate?.taskListModelDidCreate(indexPath: newIndexPath)
            }
        case .delete:
            if let indexPath {
                delegate?.taskListModelDidDelete(indexPath: indexPath)
            }
        case .update:
            if let indexPath {
                let cdTask = getCDTask(at: indexPath)
                let taskModel = TaskModel(cdTask: cdTask)
                delegate?.taskListModelDidUpdate(in: indexPath, taskModel: taskModel)
            }
        case .move:
            if let indexPath, let newIndexPath,
               let cdTask = anObject as? CDTask {
                let taskModel = TaskModel(cdTask: cdTask)
                delegate?.taskListModelDidMove(
                    fromIndexPath: indexPath,
                    toIndexPath: newIndexPath,
                    taskModel: taskModel
                )
            }

        @unknown default:
            break
        }
    }
}
