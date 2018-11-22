
import Foundation
import CoreData

// API для работы с приоритетами
protocol CrudPriority{

    var priorities:[Priority]! {get set} // хранит текущие данные, выбранные из БД

    func addOrUpdate(_ priority:Priority) // добавляет новый объект или обновляет существующий

    func getAll() -> [Priority] // получение всех объектов

    func delete(_ priority: Priority) // удаление объекта

}



