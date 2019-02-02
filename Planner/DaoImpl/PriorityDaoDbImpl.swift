
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
    
    // MARK: util
    
    // обновляет индексы у объектов в зависимости от расположения в массиве
    func updateIndexes(){
        
        for (index, item) in items.enumerated(){
            item.index = Int32(index) // присваиваем порядковый номер следования в массиве
        }
        
        save()
        
        items = getAll(sortType: .index)
    }
    
    // MARK: demo data
    
    func initDemoPriorities(){
        
        let p1 = Priority(context:context)
        p1.name = lsLowPriority
        p1.index = 1
        p1.color = UIColor.init(red: 104/255, green: 143/255, blue: 173/255, alpha: 1.0) // в формате RGBA
        
        let p2 = Priority(context:context)
        p2.name = lsNormalPriority
        p2.index = 2
        p2.color = UIColor.init(red: 0/255, green: 197/255, blue: 144/255, alpha: 1.0)
        
        let p3 = Priority(context:context)
        p3.name = lsHighPriority
        p3.index = 3
        p3.color = UIColor.init(red: 236/255, green: 100/255, blue: 75/255, alpha: 1.0)
        
        add(p1)
        add(p2)
        add(p3)
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
