import UIKit
import CoreData

class BaseCoreDataManager {
    private var managedObjectContext: NSManagedObjectContext? = nil

    func getContext() -> NSManagedObjectContext {
        if let managedObjectContext {
            return managedObjectContext
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let safeManagedObjectContext = appDelegate.persistentContainer.viewContext

            managedObjectContext = safeManagedObjectContext

            return safeManagedObjectContext
        }
    }

    func saveContext () {
        let context = getContext()

        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                // TODO: обработать ошибку нормально
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

}
