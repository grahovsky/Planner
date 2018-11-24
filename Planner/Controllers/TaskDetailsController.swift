
import UIKit

class TaskDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // текущая задача для редактирования (либо для создания новой задачи)
    var task: Task!
    
    let dateFormatter = DateFormatter()
    
    // вызывается после инициализации
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .short

    }

    // вызывается, если не хватает памяти (чтобы очистить ресурсы)
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView
    
    // 5 секций для отображения данных задач (по одной секции на каждое поле)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    // в каждой секции по одной строке
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 4 {
            return 120
        } else {
            return 45
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    // заполняет данные задачи
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // какую секцию в данный момент заполняем
        switch indexPath.section { // имя
        case 0:
            
            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskName", for: indexPath) as? TaskNameCell else {
                fatalError("cell type")
            }
            
            // заполняем компонент данными из задачи
            cell.textTaskName.text = task.name
            
            return cell
            
            
        case 1: // категория
            
            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskCategory", for: indexPath) as? TaskCategoryCell else {
                fatalError("cell type")
            }
            
            // будет хранить конечный текст для отображения
            var value:String
            
            if let name = task.category?.name {
                value = name
            } else {
                value = "Не выбрано"
            }
            
            // заполняем компонент данными из задачи
            cell.labelTaskCategory.text = value
            
            
            return cell
            
            
        case 2: // приоритет
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskPriority", for: indexPath) as? TaskPriorityCell else {
                fatalError("cell type")
            }
            
            // будет хранить конечный текст для отображения
            var value:String
            
            if let name = task.priority?.name {
                value = name
            } else {
                value = "Не выбрано"
            }
            
            // заполняем компонент данными из задачи
            cell.labelTaskPriority.text = value
            
            
            return cell
            
        case 3: // дата
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskDeadline", for: indexPath) as? TaskDeadlineCell else {
                fatalError("cell type")
            }
            
            // будет хранить конечный текст для отображения
            var value:String
            
            if let date = task.deadline {
                //dateFormatter.dateFormat = "dd/MM/yy"
                value = dateFormatter.string(from: date)
            } else {
                value = "Не указано"
            }
            
            // заполняем компонент данными из задачи
            cell.labelTaskDeadLine.text = value
            
            return cell
            
        case 4: // доп. текстовая информация
            
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskInfo", for: indexPath) as? TaskInfoCell else {
                fatalError("cell type")
            }
            
            // будет хранить конечный текст для отображения
            var value:String
            
            if let name = task.info {
                value = name
            } else {
                value = ""
            }
            
            // заполняем компонент данными из задачи
            cell.textTaskInfo.text = value
            
            return cell
            
        default:
            fatalError("cell type")
        }
    }
    
    // названия для каждой секции
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0: return "Название"
        case 1: return "Категория"
        case 2: return "Приоритет"
        case 3: return "Дата"
        case 4: return "Доп. инфо"
        default: return ""
        }
        
    }


}

