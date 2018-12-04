
import CoreData
import UIKit
import Foundation

// реализация DAO для работы с категорями
class CategoryDaoDbImpl: CommonSearchDAO {

    //для наглядности - типы для generics (можно не указывать явно, т.к. компилятор получит их из методов)
    typealias Item = Category
    typealias SortType = CategorySortType
    
    
    // паттерн синглтон
    static let current = CategoryDaoDbImpl()
    
    private init() {
        
    }
    
    var items:[Item]!

    // MARK: dao

    func getAll(sortType: SortType?) -> [Item] {

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
    func search(text: String, sortType:SortType?) -> [Item] {
        
        // объект-контейнер для выборки данных
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        // добавляем условие и параметры
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", text) // [c] - case insensitive, %@ параметр
        
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

// возможные поля для сортировки списка категорий
enum CategorySortType: Int {
    case name = 0
    
    // получить объект сортировки для добавления в fetchRequest
    func getDescriptor(_ sortType:CategorySortType) -> NSSortDescriptor{
        switch sortType {
        case .name:
            return NSSortDescriptor(key: #keyPath(Category.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        }
    }
}
