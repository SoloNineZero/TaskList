//
//  StorageManager.swift
//  TaskList
//
//  Created by Игорь Солодянкин on 04.04.2023.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()

    private var viewContext: NSManagedObjectContext

    private init() {
        viewContext = persistentContainer.viewContext

    }

    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchData(completion: @escaping (Result<[Task], Error>) -> Void)  {
        let fetchRequest = Task.fetchRequest() // запрос к БД
        
        do {
            let taskList = try viewContext.fetch(fetchRequest)
            completion(.success(taskList))
        } catch {
            completion(.failure(error))
        }
    }
    
    func saveTask(taskName: String, completion: @escaping (Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task",in: viewContext) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Task else { return }
        
        task.title = taskName
        completion(task)
        saveContext()
    }
    
    func edit(task: Task, newNameTask: String) {
        task.title = newNameTask
        saveContext()
    }
    
    func delete(task: Task) {
        viewContext.delete(task)
        saveContext()
    }
    
}
