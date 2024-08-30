
import Foundation
import CoreData

final class TaskCoreDataManager: BaseCoreDataManager {

    // MARK: - Select

    func getTasksWithSorting(isCompleted: Bool? = nil) -> [CDTask] {
        let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: "createdAt", ascending: false)
        ]

        if let isCompleted {
            fetchRequest.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: isCompleted))
        }

        do {
            let tasks = try getContext().fetch(fetchRequest)

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
            let results = try getContext().fetch(fetchRequest)
            return results.first
        } catch {
            // логировать
            return nil
        }
    }

    // MARK: - Insert

    @discardableResult
    func createWith(title: String, isCompleted: Bool = false, description: String? = nil) -> CDTask {
        let task = CDTask(context: getContext())
        task.id = UUID()
        task.createdAt = Date()
        task.title = title
        task.isCompleted = isCompleted
        task.descriptionText = description

        saveContext()

        return task
    }

    // MARK: - Update

    func updateField(isCompleted: Bool, task: CDTask) {
        task.isCompleted = isCompleted
        saveContext()
    }

    func updateField(title: String, task: CDTask) {
        task.title = title
        saveContext()
    }

    func updateField(descriptionText: String?, task: CDTask) {
        task.descriptionText = descriptionText
        saveContext()
    }

    // MARK: - Delete

    func delete(tasks: [CDTask]) {
        let context = getContext()
        for task in tasks {
            context.delete(task)
        }

        saveContext()
    }
}
