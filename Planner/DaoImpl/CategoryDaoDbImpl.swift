
import CoreData
import UIKit
import Foundation

// реализация DAO для работы с категорями
class CategoryDaoDbImpl: CommonSearchDAO {

    //для наглядности - типы для generics (можно не указывать явно, т.к. компилятор получит их из методов)
    typealias Item = Category
    
    // паттерн синглтон
    static let current = CategoryDaoDbImpl()
    
    private init() {
        
    }
    
    var items:[Item]!

    // MARK: dao

    func getAll() -> [Item] {

        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        // добавляем сортировку
        let sort = NSSortDescriptor(key: #keyPath(Category.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sort]
        
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



    func addOrUpdate(_ item:Item){

        if !items.contains(item){
            items.append(item)
        }

        save()

    }

    // поиск по имени задачи
    func search(text: String) -> [Category] {
        
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
        
        // добавляем сортировку
        let sort = NSSortDescriptor(key: #keyPath(Category.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sort]
        
        do {
            items = try context.fetch(fetchRequest) // выполняем запрос с предикатом (предикатов может быть много)
        } catch {
            fatalError("Fetching Failed")
        }
        
        return items
        
    }


}
