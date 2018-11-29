
import UIKit
import CoreData

//контроллер для отображения списка задач
class TaskListController: UITableViewController {

    let dateFormatter = DateFormatter()

    let taskDAO = TaskDaoDbImpl.current
    let categoryDAO = CategoryDaoDbImpl.current
    let priorityDAO = PriorityDaoDbImpl.current
    
    let quickTaskSection = 0
    let taskListSection = 1
    
    let sectionCount = 2
    
    var textQuickTask: UITextField!
    
    var searchController: UISearchController! // поисковый элемент, который будет добавляться поверх таблицы задач
    
    var taskCount: Int {
       return taskDAO.items.count
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let category = Category(context: categoryDAO.context)
//        category.name = "Семья"
//        try! categoryDAO.context.save()
//
//        let priority = Priority(context: priorityDAO.context)
//        priority.name = "Средний"
//        priority.index = 2
//        try! priorityDAO.context.save()
//
//        let task = Task(context: taskDao.context)
//        task.name = "Сходить в зал"
//        task.category = category
//        task.priority = priority
//        task.completed = false
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm"
//        let someDateTime = formatter.date(from: "2018/11/25 21:00")
//
//        task.deadline = someDateTime
//        try! taskDao.context.save()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        setupSearchController()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: tableView

    // методы вызываются автоматически компонентом tableView

    // сколько секций нужно отображать в таблице
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }

    // сколько будет записей в каждой секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case quickTaskSection:
            return 1
        case taskListSection:
            return taskCount
        default:
            return 0
        }
            
    }

    // отображение данных в строке
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case quickTaskSection:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellQuickTask", for: indexPath) as? QuickTaskCell else{
                fatalError("cell type")
            }
            textQuickTask = cell.textQuickTask
            textQuickTask.placeholder = "введите быструю задачу"
            return cell
        
        case taskListSection:
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTask", for: indexPath) as? TaskListCell else{
                fatalError("cell type")
            }
            
            let task = taskDAO.items[indexPath.row]
            
            cell.labelTaskName.text = task.name
            cell.labelTaskCategory.text = (task.category?.name ?? "")
            
            // задаем цвет по приоритету
            if let priority = task.priority {
                
                switch priority.index{
                case 1:
                    cell.labelPriority.backgroundColor = UIColor(named: "low")
                case 2:
                    cell.labelPriority.backgroundColor = UIColor(named: "normal")
                case 3:
                    cell.labelPriority.backgroundColor = UIColor(named: "high")
                default:
                    cell.labelPriority.backgroundColor = UIColor.white
                }
                
            } else {
                cell.labelPriority.backgroundColor = UIColor.white
            }
            
            cell.labelDeadline.textColor = .lightGray
            
            // отображать или нет иконку блокнота
            if task.info == nil || (task.info?.isEmpty)!{
                cell.buttonTaskInfo.isHidden = true // скрыть
            }else{
                cell.buttonTaskInfo.isHidden = false // показать
            }
            
            // текст для отображения кол-ва дней по задаче
            if let diff = task.daysLeft(){
                
                switch diff {
                case 0:
                    cell.labelDeadline.text = "Сегодня" // TODO: локализация
                case 1:
                    cell.labelDeadline.text = "Завтра"
                case 0...:
                    cell.labelDeadline.text = "\(diff) дн."
                    
                case ..<0:
                    cell.labelDeadline.textColor = .red
                    cell.labelDeadline.text = "\(diff) дн."
                    
                default:
                    cell.labelDeadline.text = ""
                }
                
            } else {
                cell.labelDeadline.text = ""
            }
            
            if task.completed {
                
                cell.buttonCompleteTask.setImage(UIImage(named: "check_green"), for: .normal)
                cell.labelTaskName.textColor = .lightGray
                cell.labelTaskCategory.textColor = .lightGray
                cell.labelDeadline.textColor = .lightGray
                cell.buttonTaskInfo.setImage(UIImage(named: "note_gray"), for: .normal)
                cell.labelPriority.backgroundColor = UIColor.lightGray
                
                cell.selectionStyle = .none // не отображаем выделение выбранной строки
                
            } else {
                
                cell.buttonCompleteTask.setImage(UIImage(named: "check_gray"), for: .normal)
                cell.labelTaskName.textColor = .black
                cell.labelTaskCategory.textColor = .black
                cell.labelDeadline.textColor = .black
                cell.buttonTaskInfo.setImage(UIImage(named: "note"), for: .normal)
                
                cell.selectionStyle = .default
                
            }
            
            return cell
            
        default:
            
            return UITableViewCell()
            
        }

    }
    
    // установка высоты строки
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 40
        default:
            return 60
        }
    }
    
 
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        let delete = UITableViewCell.EditingStyle.delete
        
        return delete
        
    }
    
    // собственные наборы действий для строк
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        switch indexPath.section {
//        case taskListSection:
//            let delete  = UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
//                self.deleteTask(indexPath)
//            }
//            return [delete]
//        default:
//            return []
//        }
//
//    }
    
    // какие строки можно редактировать
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == quickTaskSection {
            return false
        }
        
        return true
        
    }
    
    // удаление строки не используется, т.к. editActionsForRowAt
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if indexPath.section == taskListSection {

            if editingStyle == .delete {

                deleteTask(indexPath)

            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }

        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section != quickTaskSection else { return }
        
        let task = taskDAO.items[indexPath.row]
        
        if task.completed {
            return
        }
        
        performSegue(withIdentifier: "UpdateTask", sender: tableView.cellForRow(at: indexPath))
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        switch segue.identifier { // проверяем название segue
        case "UpdateTask":
            
            // приводим sender к типу ячейки
            let selectedCell = sender as! TaskListCell
            
            // получаем доступ к целевому контроллеру segue.destination
            guard let controller = segue.destination as? TaskDetailsController else { fatalError("error") }
            
            // получаем индекс по номеру выбранной ячейки
            let selectedIndex = (tableView.indexPath(for: selectedCell)?.row)!
            
            // получаем выбранную задачу
            let selectedTask = taskDAO.items[selectedIndex]

            controller.title = "Редактирование"
            controller.task = selectedTask
            controller.delegаte = self
        
        case "CreateTask":
            
            guard let controller = segue.destination as? TaskDetailsController else { fatalError("error") }
            
            let task = Task(context: taskDAO.context)
            // task.name = "Новая задача"
            task.name = nil
            
            controller.title = "Создание"
            controller.task = task
            controller.delegаte = self
            
        default:
            return
        }
    
    }
    
    //MARK: actions
    @IBAction func  deleteFromTaskDetails(segue: UIStoryboardSegue) {
     
        guard segue.source is TaskDetailsController else { return }
        
        if segue.identifier == "DeleteTaskFromDetails", let selectedIndexPath = tableView.indexPathForSelectedRow {
            
            deleteTask(selectedIndexPath)
            
        }
        
    }
    
    @IBAction func  completeFromTaskDetails(segue: UIStoryboardSegue) {
        
        guard segue.source is TaskDetailsController else { return }
        
        if segue.identifier == "CompleteTaskFromDetails", let selectedIndexPath = tableView.indexPathForSelectedRow {
            
            completeTask(selectedIndexPath)
            
        }
        
    }
    
    //MARK: DAO
    
    func deleteTask(_ indexPath: IndexPath) {
        
        let task = taskDAO.items[indexPath.row]
        
        taskDAO.delete(task) // удалить задачу из БД
        
        // удалить саму строку и объект из коллекции (массива)
        taskDAO.items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .top)
        
    }
    
    func completeTask(_ indexPath: IndexPath) {
        
        let task = taskDAO.items[indexPath.row]
        task.completed = !task.completed
        taskDAO.addOrUpdate(task)
        
        // обновляем вид нажатой строки
        tableView.reloadRows(at: [indexPath], with: .fade)
        
    }

    @IBAction func tapCompleteTask(_ sender: UIButton) {
    
        // определяем индекс строки по нажатой кнопке в ячейке
        let viewPosition = sender.convert(CGPoint.zero, to: tableView) // координата относительно tableView
        let indexPath = tableView.indexPathForRow(at: viewPosition)!
        
        // принимаем вызов только из TaskListCell
        guard (tableView.cellForRow(at: indexPath) as? TaskListCell) != nil else { fatalError("cell type") }
        
        completeTask(indexPath)
        
    }
    
    @IBAction func quickTaskAdd(_ sender: UITextField) {
    
        let task = Task(context: taskDAO.context)
        task.name = sender.text
        sender.text = nil
        createTask(task)
    
    }
    
    func createTask(_ task: Task) {
        
        if let name = task.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            task.name = name
        } else {
            task.name = "Новая задача"
        }
        
        taskDAO.addOrUpdate(task)
        
        // индекс для новой задачи
        let indexPath = IndexPath(item: taskCount-1, section: taskListSection)
        
        // вставляем запись в конец списка
        tableView.insertRows(at: [indexPath], with: .top)
        
    }
    
    
}

//MARK: ActionResultDelegate

extension TaskListController: ActionResultDelegate {

    // может обрабатывать ответы (слушать действия) от любых контроллеров
    func done(source: UIViewController, data: Any?) {
        
        //если пришел ответ от TaskDetailsController
        if source is TaskDetailsController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow { // определяем выбранную строку
                
                taskDAO.save() // сохраняем измененную задачу (все изменения контекста)
                tableView.reloadRows(at: [selectedIndexPath], with: .fade) // обновляем строку (не всю таблицу)
                
            } else {
                
                let task = data as! Task
                
                createTask(task)
                
            }
        }
        
    }
    
    func cancel(source: UIViewController, data: Any?) {
        
    }

}

//обработка действий при поиске
extension TaskListController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // вызывается после каждого нажатия или когда просто активируется поиск
        // не используем
        // будем использовать searchBarTextDidEndEditing при окончании ввода текста
    }


}

extension TaskListController: UISearchBarDelegate {
    
    // обязательно нажать Найти для поиска
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    // поиск после окончания ввода данных нажатия Найти
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if !(searchController.searchBar.text?.isEmpty)! { // искать только если есть текст
            taskDAO.search(text: searchController.searchBar.text!)
            tableView.reloadData()
        }
    }
    
    // при отмене поиска показываем все записи
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = ""
        taskDAO.getAll()
        tableView.reloadData()
    }
    
    func setupSearchController() {
        
        searchController = UISearchController(searchResultsController: nil) // nil - отоброжение результата поиска в этом же view
        
        searchController.dimsBackgroundDuringPresentation = false // затемнять фон при поиске (затемненная область не доступна)
        
        definesPresentationContext = true // для правильного отображения внутри таблицы, без параметра может выходить поверх таблицы
        
        searchController.searchBar.placeholder = "Поиск по названию"
        searchController.searchBar.backgroundColor = .white
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        searchController.searchBar.showsScopeBar = false // чтобы не показывалось ничего под строкой поиска
        
        // из-за особенностей реализации от версии iOS
        if #available(iOS 11.0, *) { // для iOS 11 и выше
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
    }
    
}
