
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с задачами
class TaskDaoDbImpl: Crud{

    //для наглядности - типы для generics (можно не указывать явно, т.к. компилятор получит их из методов)
    typealias Item = Task
    
    // доступ к другим DAO
    let categoryDao = CategoryDaoDbImpl.current
    let priorityDao = PriorityDaoDbImpl.current

    var items: [Item]! // актуальные объекты, которые были выбраны из БД

    // синглтон
    static let current = TaskDaoDbImpl()
   
    private init(){}

    // MARK: dao

    func getAll() -> [Item] {

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        do {
            items = try context.fetch(fetchRequest)
        } catch {
            fatalError("Fetching Failed")
        }

        return items

    }



    func delete(_ item: Item) {
        context.delete(item)
        save()
    }



    func addOrUpdate(_ item: Item)  {
        if !items.contains(item){
            items.append(item)
        }

        save()
    }






}


