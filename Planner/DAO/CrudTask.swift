
import Foundation
import CoreData

// API для работы с задачами
protocol CrudTask{

    var tasks:[Task]! {get set} // хранит текущие данные, выбранные из БД

    func addOrUpdate(_ task:Task) // добавляет новый объект или обновляет существующий

    func getAll() -> [Task] // получение всех объектов

    func delete(_ task: Task) // удаление объекта

}


