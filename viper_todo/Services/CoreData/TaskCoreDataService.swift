
import Foundation
import CoreData

final class TaskCoreDataService {

    private let coreDataStack: CoreDataStack

    // MARK: - Init
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - Select

    func getTasksWithSorting(isCompleted: Bool? = nil) -> [CDTask] {
        let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: "createdAt", ascending: false)
        ]

        if let isCompleted {
            fetchRequest.predicate = NSPredicate(
                format: "isCompleted == %@",
                NSNumber(value: isCompleted)
            )
        }

        do {
            let tasks = try coreDataStack.context.fetch(fetchRequest)

            return tasks
        } catch let error as NSError {
            // TODO: обработать ошибку нормально
            fatalError("getAllTasks error - \(error)")
        }
    }

    func getTaskBy(id: UUID) -> CDTask? {
        let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try coreDataStack.context.fetch(fetchRequest)
            return results.first
        } catch {
            // логировать
            return nil
        }
    }

    // MARK: - Insert

    @discardableResult
    func createWith(title: String, isCompleted: Bool = false, description: String? = nil) -> CDTask {
        let task = CDTask(context: coreDataStack.context)
        task.id = UUID()
        task.createdAt = Date()
        task.title = title
        task.isCompleted = isCompleted
        task.descriptionText = description

        coreDataStack.saveContext()

        return task
    }

    // MARK: - Update

    func updateField(isCompleted: Bool, task: CDTask) {
        task.isCompleted = isCompleted
        coreDataStack.saveContext()
    }

    func updateField(title: String, task: CDTask) {
        task.title = title
        coreDataStack.saveContext()
    }

    func updateField(descriptionText: String?, task: CDTask) {
        task.descriptionText = descriptionText
        coreDataStack.saveContext()
    }

    // MARK: - Delete

    func delete(tasks: CDTask...) {
        for task in tasks {
            coreDataStack.context.delete(task)
        }

        coreDataStack.saveContext()
    }
}
