
import UIKit
import CoreData

//контроллер для отображения списка задач
class TaskListController: UITableViewController {

    let dateFormatter = DateFormatter()

    let taskDAO = TaskDaoDbImpl.current
    let categoryDAO = CategoryDaoDbImpl.current
    let priorityDAO = PriorityDaoDbImpl.current

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
//
//        // симулятор загрузки формы (чтобы успеть посмотреть launchscreen) - в рабочем проекте естественно нужно будет удалить
//        for i in 0...200000 {
//            print(i)
//        }




//        db.initData()// запускаем только 1 раз для заполнения таблиц

        // taskList = taskDAO.getAll()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   


    




    // MARK: tableView

    // методы вызываются автоматически компонентом tableView

    // сколько секций нужно отображать в таблице
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // сколько будет записей в каждой секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskDAO.items.count
    }



    // отображение данных в строке
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellTask", for: indexPath) as? TaskListCell else{
            fatalError("cell type")
        }

        let task = taskDAO.items[indexPath.row]

        cell.labelTaskName.text = task.name
        cell.labelTaskCategory.text = (task.category?.name ?? "")


        // задаем цвет по приоритету
        if let priority = task.priority{

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

        }else{
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

        }else{
            cell.labelDeadline.text = ""
        }


        return cell
    }

    // установка высоты строки
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    // удаление строки
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            deleteTask(indexPath)

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
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
    
    //MARK: DAO
    
    func deleteTask(_ indexPath: IndexPath) {
        
        let task = taskDAO.items[indexPath.row]
        
        taskDAO.delete(task) // удалить задачу из БД
        
        // удалить саму строку и объект из коллекции (массива)
        taskDAO.items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .top)
        
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
                
            }
        }
        
    }
    
    func cancel(source: UIViewController, data: Any?) {
        
    }

}
