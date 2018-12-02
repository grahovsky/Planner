
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с задачами
class TaskDaoDbImpl: CommonSearchDAO {

    //для наглядности - типы для generics (можно не указывать явно, т.к. компилятор получит их из методов)
    typealias Item = Task
    
    typealias SortType = TaskSortType
    
    // доступ к другим DAO
    let categoryDAO = CategoryDaoDbImpl.current
    let priorityDAO = PriorityDaoDbImpl.current

    var items: [Item]! // актуальные объекты, которые были выбраны из БД

    // синглтон
    static let current = TaskDaoDbImpl()
    private init(){}

    // MARK: dao

    func getAll(sortType:SortType?) -> [Item] {

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        // добавляем поле для сортировки
        if let sortType = sortType {
            fetchRequest.sortDescriptors = [sortType.getDescriptor(sortType)] // в зависимости от значения sortType - получаем нужное поле для сортировки
        }
        
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
    func search(text: String, sortType:SortType?) -> [Item] {
        
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
        
        // добавляем поле для сортировки
        if let sortType = sortType{
            fetchRequest.sortDescriptors = [sortType.getDescriptor(sortType)] // в зависимости от значения sortType - получаем нужное поле для сортировки
        }
        
        do {
            items = try context.fetch(fetchRequest) // выполняем запрос с предикатом (предикатов может быть много)
        } catch {
            fatalError("Fetching Failed")
        }
        
        return items
        
        
    }

}

// возможные поля для сортировки списка задач
enum TaskSortType: Int {
    
    // порядок case'ов должен совпадать с порядком кнопок сортировки (scope buttons)
    case name = 0
    case priority
    case deadline
    
    // получить объект сортировки для добавления в fetchRequest
    func getDescriptor(_ sortType:TaskSortType) -> NSSortDescriptor{
        switch sortType {
        case .name:
            return NSSortDescriptor(key: #keyPath(Task.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        case .deadline:
            return NSSortDescriptor(key: #keyPath(Task.deadline), ascending: true)
        case .priority:
            return NSSortDescriptor(key: #keyPath(Task.priority.index), ascending: false) // ascending: false - в начале списка будут важные задачи
        }
    }
    
}
