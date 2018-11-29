
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с задачами
class TaskDaoDbImpl: CommonSearchDAO {

    //для наглядности - типы для generics (можно не указывать явно, т.к. компилятор получит их из методов)
    typealias Item = Task
    
    // доступ к другим DAO
    let categoryDAO = CategoryDaoDbImpl.current
    let priorityDAO = PriorityDaoDbImpl.current

    var items: [Item]! // актуальные объекты, которые были выбраны из БД

    // синглтон
    static let current = TaskDaoDbImpl()
   
    private init() {
        items = getAll()
    }

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

    // поиск по имени задачи
    func search(text: String) -> [Task] {
        
        // объект-контейнер для выборки данных
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        // объект-контейнер для добавления условий
        var predicate: NSPredicate
        // массив параметров любого типа
        var params = [Any]()
        
        // прописываем само условие
        let sql = "name CONTAINS[c] %@" // [c] - case insensitive, %@ параметр
        
        params.append(text) // указываем значение параметров
        
        // добавляем условие и параметры
        predicate = NSPredicate(format: sql, argumentArray: params)
        
        // добавляем предикат в контейнер запоса
        fetchRequest.predicate = predicate
        
        do {
            items = try context.fetch(fetchRequest) // выполняем запрос с предикатом (предикатов может быть много)
        } catch {
            fatalError("Fetching Failed")
        }
        
        return items
        
        
    }




}


