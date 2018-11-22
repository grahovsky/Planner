
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с задачами
class TaskDaoDbImpl: CrudTask{

    var context:NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // контекст для работы с БД
    }

    // сохранение всех изменений контекста
    func save(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }



    // доступ к другим DAO
    let categoryDao = CategoryDaoDbImpl.current
    let priorityDao = PriorityDaoDbImpl.current

    var tasks: [Task]! // актуальные объекты, которые были выбраны из БД


    // синглтон
    static let current = TaskDaoDbImpl()
    private init(){}


    // MARK: dao

    func getAll() -> [Task] {

        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            tasks = try context.fetch(fetchRequest)
        } catch {
            fatalError("Fetching Failed")
        }

        return tasks

    }



    func delete(_ task: Task) {
        context.delete(task)
        save()
    }



    func addOrUpdate(_ task: Task)  {
        if !tasks.contains(task){
            tasks.append(task)
        }

        save()
    }






}


