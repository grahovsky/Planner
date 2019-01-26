
import UIKit
import SwiftIconFont

// в какой секции какие данные будут храниться (во избежание антипаттерна magic number)
enum Section: Int {
    case Name = 0
    case Category = 1
    case Priority = 2
    case Deadline = 3
    case Info = 4
}

class TaskDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonComplete: UIButton!
    
    // текущая задача для редактирования (либо для создания новой задачи)
    var task: Task!
    
    // поля для задачи, чтобы не работать напрямую с сылкой
    var taskName: String?
    var taskInfo: String?
    var taskPriority: Priority?
    var taskCategory: Category?
    var taskDeadline: Date?
    
    var delegаte: ActionResultDelegate! // для уведомления и вызова функции из контроллера списка задач
    
    var mode:TaskDetailsMode!
    
    // для хранения ссылок на компоненты из ячеек
    var textTaskName: UITextField!
    var textTaskInfo: UITextView!
    var buttonDatetimePicker: UIButton!
    
    // вызывается после инициализации
    override func viewDidLoad() {
        super.viewDidLoad()

        if mode == .update { //при обновлении
            taskName = task.name
            taskInfo = task.info
            taskPriority = task.priority
            taskCategory = task.category
            taskDeadline = task.deadline
        }
        
        hideKeyboardWhenTappedAround()
        
        initButtons()

    }

    // вызывается, если не хватает памяти (чтобы очистить ресурсы)
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: init
    
    func initButtons() {
        
        // указываем иконки для кнопок (вместо текста)
        buttonDelete.titleLabel?.font = UIFont.icon(from: .fontAwesome, ofSize: 18.0)
        buttonDelete.titleLabel?.tintColor = UIColor.white
        buttonDelete.setTitle(String.fontAwesomeIcon("trash"), for: .normal)
        
        buttonComplete.titleLabel?.font = UIFont.icon(from: .fontAwesome, ofSize: 18.0)
        buttonComplete.titleLabel?.tintColor = UIColor.white
        buttonComplete.setTitle(String.fontAwesomeIcon("check"), for: .normal)
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
        case Section.Name.rawValue:
            
            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskName", for: indexPath) as? TaskNameCell else {
                fatalError("cell type")
            }
            
            // заполняем компонент данными из задачи
            cell.textTaskName.text = taskName
            
            if (cell.textTaskName.text?.isEmpty)! {
                cell.textTaskName.becomeFirstResponder()
            }
            
            textTaskName = cell.textTaskName //для использования компонента вне метода tableView
            
            return cell
            
            
        case Section.Category.rawValue: // категория
            
            // получаем ссылку на ячейку
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskCategory", for: indexPath) as? TaskCategoryCell else {
                fatalError("cell type")
            }
            
            // будет хранить конечный текст для отображения
            var value:String
            
            if let name = taskCategory?.name {
                value = name
                cell.labelTaskCategory.textColor = .darkText
            } else {
                value = "Не выбрано"
                cell.labelTaskCategory.textColor = .lightGray
            }
            
            // заполняем компонент данными из задачи
            cell.labelTaskCategory.text = value
            
            
            return cell
            
            
        case Section.Priority.rawValue: // приоритет
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskPriority", for: indexPath) as? TaskPriorityCell else {
                fatalError("cell type")
            }
            
            // будет хранить конечный текст для отображения
            var value:String
            
            if let name = taskPriority?.name {
                value = name
                cell.labelTaskPriority.textColor = .darkText
            } else {
                value = "Не выбрано"
                cell.labelTaskPriority.textColor = .lightGray
            }
            
            // заполняем компонент данными из задачи
            cell.labelTaskPriority.text = value
            
            
            return cell
            
        case Section.Deadline.rawValue: // дата
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskDeadline", for: indexPath) as? TaskDeadlineCell else {
                fatalError("cell type")
            }
            
            //запомним ссылку на элемент ячейки
            buttonDatetimePicker = cell.buttonDatetimePicker
            
            // будет хранить конечный текст для отображения
            var value:String
            
            if let date = taskDeadline {
                
                let dateFormatter = createDateFormatter()
                //dateFormatter.dateFormat = "dd/MM/yy"
                value = dateFormatter.string(from: date)
                cell.buttonDatetimePicker.setTitleColor(.gray, for: .normal)
                cell.buttonClearDeadline.isHidden = false
            } else {
                value = "Не указано"
                cell.buttonDatetimePicker.setTitleColor(.lightGray, for: .normal)
                cell.buttonClearDeadline.isHidden = true
            }
            
            // заполняем компонент данными из задачи
            cell.buttonDatetimePicker.setTitle(value, for: .normal)
            
            
            handleDeadline(label: cell.labelDeadline, data: taskDeadline)
            
            return cell
            
        case Section.Info.rawValue: // доп. текстовая информация
            
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTaskInfo", for: indexPath) as? TaskInfoCell else {
                fatalError("cell type")
            }
            
            // заполняем компонент данными из задачи
            if taskInfo != nil {
                cell.textTaskInfo.text = taskInfo
                cell.textTaskInfo.textColor = UIColor.darkGray
            } else { // либо пишем подсказку
                cell.textTaskInfo.text = "Нажмите для заполнения"
                cell.textTaskInfo.textColor = UIColor.lightGray
            }
            
            textTaskInfo = cell.textTaskInfo
            
            return cell
            
        default:
            fatalError("cell type")
        }
    }
    
    // названия для каждой секции
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case Section.Name.rawValue: return "Название"
        case Section.Category.rawValue: return "Категория"
        case Section.Priority.rawValue: return "Приоритет"
        case Section.Deadline.rawValue: return "Дата"
        case Section.Info.rawValue: return "Доп. инфо"
        default: return ""
        }
        
    }

    // MARK: @IBActions
    
    
    // закрытие контроллера без сохранения
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        
       closeController()
        
    }
    
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
    
        if task == nil {
            task = Task(context: TaskDaoDbImpl.current.context)
        }
        
        if let taskName = taskName, !taskName.isEmpty {
            task.name = taskName
        } else {
            task.name = "Новая задача"
        }
        task.info = textTaskInfo.text
        task.category = taskCategory
        task.priority = taskPriority
        task.deadline = taskDeadline
        
        delegаte.done(source: self, data: task)
        
        closeController()
        
    }
    
    @IBAction func taskNameChanged(_ sender: UITextField) {
        
        taskName = textTaskName.text
        
    }
    
    
    @IBAction func tapDeleteTask(_ sender: UIButton) {
        
        confirmAction(text: "Действительно хотите удалить задачу?") {
            self.performSegue(withIdentifier: "DeleteTaskFromDetails", sender: self) // реализация замыкания (trailing closure), которое передается как параметр
        }
    
    }
    
    
    @IBAction func tapCompleteTask(_ sender: UIButton) {
        
        confirmAction(text: "Действительно хотите выполнить задачу?") {
            self.performSegue(withIdentifier: "CompleteTaskFromDetails", sender: self)
        }

    }
    
    @IBAction func tapDatetimePicker(_ sender: UIButton) {
        // если нужны доп. действия
    }
    
    
    @IBAction func tapDateClear(_ sender: UIButton) {
    
        taskDeadline = nil
        
        // определяем индекс строки по нажатой кнопке в ячейке
        // let viewPosition = sender.convert(CGPoint.zero, to: tableView) // координата относительно tableView
        // let indexPath = tableView.indexPathForRow(at: viewPosition)!
        
        // обращаемся к 0 строке секции Deadline
        tableView.reloadRows(at: [IndexPath(row: 0, section: Section.Deadline.rawValue)], with: .none)
        
    }
    
    
    // MARK: prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == nil {
            return
        }
        
        switch segue.identifier! {
        case "SelectCategory":
            if let controller = segue.destination as? CategoryListController {
                controller.selectedItem = taskCategory
                controller.delegаte = self
                controller.navigationTitle = "Выбор"
                controller.showMode = .select
            }
        case "SelectPriority":
            if let controller = segue.destination as? PriorityListController {
                controller.selectedItem = taskPriority
                controller.delegаte = self
                controller.navigationTitle = "Выбор"
                controller.showMode = .select
            }
        case "EditTaskInfo":
            if let controller = segue.destination as? TaskInfoController {
                controller.taskInfo = taskInfo
                controller.delegаte = self
                controller.navigationTitle = "Редактирование"
                controller.taskInfoShowMode = .edit
            }
        case "SelectDatetime":
            if let controller = segue.destination as? DatetimePickerController {
                controller.initDeadLine = taskDeadline
                controller.delegate = self
            }
        default:
            return
        }
        
    }
    
}

extension TaskDetailsController: ActionResultDelegate {
    
    func done(source: UIViewController, data: Any?) {
        
        switch source {
        case is CategoryListController:
            
            taskCategory = data as? Category
            
            tableView.reloadRows(at: [IndexPath(row: 0, section: Section.Category.rawValue)], with: .fade)
            
        case is PriorityListController:
            
            taskPriority = data as? Priority
            
            tableView.reloadRows(at: [IndexPath(row: 0, section: Section.Priority.rawValue)], with: .fade)
       
        case is TaskInfoController:
            
            taskInfo = data as? String
            
//            tableView.reloadRows(at: [IndexPath(row: 0, section: Section.Info.rawValue)], with: .fade)
            
            textTaskInfo.text = taskInfo
            
        case is DatetimePickerController:
            
            let dateFormatter = createDateFormatter()
            
            taskDeadline = data as? Date
            buttonDatetimePicker.setTitle(dateFormatter.string(from: taskDeadline!), for: .normal)
            
            tableView.reloadRows(at: [IndexPath(row: 0, section: Section.Deadline.rawValue)], with: .fade)
                
        default:
            print()
        }
        
    }
    
    func cancel(source: UIViewController, data: Any?) {
    
    }
    
    
}

enum TaskDetailsMode{
    case add
    case update
}
