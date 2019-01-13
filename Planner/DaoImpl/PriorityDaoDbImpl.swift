
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с приоритетами
class PriorityDaoDbImpl: DictDAO, CommonSearchDAO{
    
    //для наглядности - типы для generics (можно не указывать явно, т.к. компилятор получит их из методов)
    typealias Item = Priority
    
    typealias SortType = PrioritySortType
    
    // паттерн синглтон
    static let current = PriorityDaoDbImpl()
    
    private init() {
        getAll(sortType: PrioritySortType.index)
    }

    var items:[Item]!

    // MARK: dao

    func getAll(sortType: SortType?) -> [Item] {
        
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

// возможные поля для сортировки списка приоритетов
enum PrioritySortType: Int{
    case index = 0
    
    // получить объект сортировки для добавления в fetchRequest
    func getDescriptor(_ sortType:PrioritySortType) -> NSSortDescriptor{
        switch sortType {
        case .index:
            return NSSortDescriptor(key: #keyPath(Priority.index), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        }
    }
}
