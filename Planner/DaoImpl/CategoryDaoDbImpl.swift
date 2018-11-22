
import CoreData
import UIKit
import Foundation

// реализация DAO для работы с категорями
class CategoryDaoDbImpl: CrudCategory{

    var context:NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // контекст для работы с БД
    }

    // сохранение всех изменений контекста
    func save(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }



    // паттерн синглтон
    static let current = CategoryDaoDbImpl()
    private init(){}


    var categories:[Category]!


    // MARK: dao

    func getAll() -> [Category] {

        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()

        do {
            categories = try context.fetch(fetchRequest)
        } catch {
            fatalError("Fetching Failed")
        }

        return categories

    }


    func delete(_ category: Category) {
        context.delete(category)
        save()
    }



    func addOrUpdate(_ category:Category){

        if !categories.contains(category){
            categories.append(category)
        }

        save()

    }



}
