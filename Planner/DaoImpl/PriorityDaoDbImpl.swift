
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с приоритетами
class PriorityDaoDbImpl : CrudPriority{

    var context:NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // контекст для работы с БД
    }

    // сохранение всех изменений контекста
    func save(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }


    // паттерн синглтон
    static let current = PriorityDaoDbImpl()
    private init(){}


    
    var priorities:[Priority]!



    // MARK: dao

    func getAll() -> [Priority] {
        let fetchRequest: NSFetchRequest<Priority> = Priority.fetchRequest()

        do {
            priorities = try context.fetch(fetchRequest)
        } catch {
            fatalError("Fetching Failed")
        }

        return priorities
    }



    func delete(_ priority: Priority) {
        context.delete(priority)
        save()
    }



    func addOrUpdate(_ priority: Priority){
        if !priorities.contains(priority){
            priorities.append(priority)
        }

        save()
    }




 
}
