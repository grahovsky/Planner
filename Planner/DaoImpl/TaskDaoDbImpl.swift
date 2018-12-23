
import Foundation
import UIKit
import CoreData

// реализация DAO для работы с задачами
class TaskDaoDbImpl: TaskSearchDAO {
    
    typealias CategoryItem = Category
    
  
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
    func search(text: String?, categories: [Category], priorities: [Priority], sortType: TaskSortType?, showTasksEmptyCategories: Bool, showTasksEmptyPriorities: Bool, showTasksEmptyDates: Bool, showTasksCompleted: Bool) -> [Task] {
        
        // объект-контейнер для выборки данных
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        
        // объект-контейнер для добавления условий
        var predicates = [NSPredicate]()
        // массив параметров любого типа
       
        if let text = text {
            predicates.append(NSPredicate(format: "name CONTAINS[c] %@", text)) // [c] - case insensitive, %@ параметр
        }
 
        //фильтрация по категориям
        if !showTasksEmptyCategories {
            predicates.append(NSPredicate(format: "category IN %@", categories))
        } else {
            predicates.append(NSPredicate(format: "category = nil or category IN %@", categories))
        }
        
        // фильтрация по приоритетам
        if !showTasksEmptyPriorities {
            predicates.append(NSPredicate(format: "priority IN %@", priorities))
        } else {
            predicates.append(NSPredicate(format: "priority = nil or priority IN %@", priorities))
        }
        
        // не показывать задачи без приоритета
        if !showTasksEmptyDates {
            predicates.append(NSPredicate(format: "deadline != nil"))
        }
        
        // не показывать задачи без приоритета
        if !showTasksCompleted {
            predicates.append(NSPredicate(format: "completed == false"))
        }
        
        // собираем предикаты
        // where добавлять вручную нигде добавлять не нужно (Core Data сам построит правильный запрос
        let allPredicates = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: predicates) // все предикаты будут с условием И (AND)
        
        // объект-контейнер для добавления условий
        fetchRequest.predicate = allPredicates // добавляем предикат в контейнер запоса
        
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
