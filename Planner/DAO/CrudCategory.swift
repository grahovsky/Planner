
import Foundation
import CoreData

// API для работы с категориями
protocol CrudCategory{

    var categories:[Category]! {get set} // хранит текущие данные, выбранные из БД

    func addOrUpdate(_ category:Category) // добавляет новый объект или обновляет существующий

    func getAll() -> [Category] // получение всех объектов

    func delete(_ category: Category) // удаление объекта

}



