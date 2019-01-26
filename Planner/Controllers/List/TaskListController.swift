
import UIKit
import CoreData
import SideMenu
import SwiftIconFont
import Toaster

//контроллер для отображения списка задач
class TaskListController: UITableViewController {
    
    let taskDAO = TaskDaoDbImpl.current
    let categoryDAO = CategoryDaoDbImpl.current
    let priorityDAO = PriorityDaoDbImpl.current
    
    var currentScopeIndex = 0 // текущая выбранная кнопка сортировки в search bar
    
    let quickTaskSection = 0
    let taskListSection = 1
    
    let sectionCount = 2
    
    var textQuickTask: UITextField!
    
    var searchController: UISearchController! // поисковый элемент, который будет добавляться поверх таблицы задач
    
    // для сокращения кода
    var searchBar:UISearchBar{
        return searchController.searchBar
    }
    
    var taskCount: Int {
        return taskDAO.items.count
    }
    
    var searchBarActive = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        taskDAO.getAll(sortType: TaskSortType(rawValue: currentScopeIndex)!)
        
        setupSearchController()
        
        initSlideMenu()
        
        initIcons()
        
        // initContextListeners() только для отладки
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: core data context listeners
    
    // слушатели изменений контекста Core Data
    func initContextListeners(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contextWillSave(_:)), name: Notification.Name.NSManagedObjectContextWillSave, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(_:)), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    @objc func contextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print("--- INSERTS ---")
            for insert in inserts {
                print(insert.changedValues())
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("--- UPDATES ---")
            for update in updates {
                print(update.changedValues())
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("--- DELETES ---")
            print(deletes)
        }
        
    }
    
    @objc func contextWillSave(_ notification: Notification) {
        print(notification)
    }
    
    @objc func contextDidSave(_ notification: Notification) {
        print(notification)
    }
    
    
    // MARK: init
    
    func initSlideMenu(){
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "SideMenu") as? UISideMenuNavigationController
        
        //        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.view)
        //        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        
        //        SideMenuManager.default.menuEnableSwipeGestures = false
        
        // чтобы не затемнялся верхний статус бар
        SideMenuManager.default.menuFadeStatusBar = false
        
        
    }
    
    func initIcons(){
        navigationItem.rightBarButtonItem?.icon(from: .themify, code: "plus", ofSize: 20)
        navigationItem.leftBarButtonItem?.icon(from: .themify, code: "menu", ofSize: 20)
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
                cell.labelPriority.backgroundColor = priority.color as? UIColor
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
            handleDeadline(label: cell.labelDeadline, data: task.deadline)
            
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
    
    // удаление строки не используется, т.к. editActionsForRowAt // уже используется
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
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier { // проверяем название segue
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
            controller.mode = TaskDetailsMode.update
            
        case "CreateTask":
            
            guard let controller = segue.destination as? TaskDetailsController else { fatalError("error") }
            
            controller.title = "Создание"
            controller.task = nil //создаем задачу только после сохранения
            controller.delegаte = self
            controller.mode = TaskDetailsMode.add
            
        case "ShowTaskInfo": // переходим в контроллер для просмотра доп. инфо
            
            // определить индекс строки таблицы для нажатой кнопки
            let button = sender as! UIButton
            let buttonPosition = button.convert(CGPoint.zero, to: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: buttonPosition)!
            
            // определяем задачу, для которой нажали на кнопку блокнота
            let selectedTask = taskDAO.items[indexPath.row]
            
            
            // получаем доступ к целевому контроллеру
            guard let controller = segue.destination as? TaskInfoController else { // segue.destination - целевой контроллер
                fatalError("error")
            }
            
            controller.taskInfo = selectedTask.info // передаем текущее значение
            //                controller.delegate = self // для возврата результата действий
            controller.navigationTitle = selectedTask.name
            controller.taskInfoShowMode = .readOnly
            
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
    
    //MARK: update table
    
    func updateTable() {
        
        let sortType = TaskSortType(rawValue: PrefsManager.current.sortType)! // определяем тип сортировки по текущему выбранному значению scope button из search bar
        
        // усли активен режим поиска и текст не пустой
        if searchBarActive && searchController.searchBar.text != nil && !(searchController.searchBar.text?.isEmpty)! {
            taskDAO.search(text: searchController.searchBar.text!, categories: categoryDAO.checkedItems(), priorities: priorityDAO.checkedItems(), sortType: sortType, showTasksEmptyCategories: PrefsManager.current.showEmptyCategories, showTasksEmptyPriorities: PrefsManager.current.showEmptyPriorities, showTasksEmptyDates: PrefsManager.current.showTasksWithoutDate, showTasksCompleted: PrefsManager.current.showCompletedTasks)
        } else { // без поиска
            taskDAO.search(text: nil, categories: categoryDAO.checkedItems(), priorities: priorityDAO.checkedItems(), sortType: sortType, showTasksEmptyCategories: PrefsManager.current.showEmptyCategories, showTasksEmptyPriorities: PrefsManager.current.showEmptyPriorities, showTasksEmptyDates: PrefsManager.current.showTasksWithoutDate, showTasksCompleted: PrefsManager.current.showCompletedTasks)
        }
        
        tableView.reloadData()
        
        updateTableBackground(tableView, count: taskCount)
        
    }
    
    
    @IBAction func updateTask(segue: UIStoryboardSegue) {
        
        if let source = segue.source as? FiltersController, source.changed, segue.identifier == "FilterTasks" {
            updateTable()
        }
        
        // изменение при редактировании категорий
        if let source = segue.source as? CategoryListController, source.changed, segue.identifier == "UpdateTasksCategories" {
            updateTable()
        }
        
        // изменение при редактировании приоритетов
        if let source = segue.source as? PriorityListController, source.changed, segue.identifier == "UpdateTasksPriorities" {
            updateTable()
        }
        
    }
    
    //MARK: DAO
    
    func deleteTask(_ indexPath: IndexPath) {
        
        let task = taskDAO.items[indexPath.row]
        
        taskDAO.delete(task) // удалить задачу из БД
        taskDAO.items.remove(at: indexPath.row)
        
        // удалить саму строку и объект из коллекции (массива)
        if taskDAO.items.isEmpty {
            tableView.deleteSections(IndexSet([taskListSection]), with: .left)
        } else {
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        
    }
    
    func completeTask(_ indexPath: IndexPath) {
        
        let task = taskDAO.items[indexPath.row]
        task.completed = !task.completed
        taskDAO.addOrUpdate(task)
        tableView.reloadRows(at: [indexPath], with: .fade)
        
        // показать анимацию обновления строки с задержкой, и только затем скрыть строку (при необходимости)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            
            // если отключен показ завершенных задач
            if !PrefsManager.current.showCompletedTasks {
                
                
                // удалить задачу из коллекции и таблицы
                self.taskDAO.items.remove(at: indexPath.row)
                
                // если это последняя запись - удаляем всю секцию, иначе будет ошибка при попытке отображения таблицы
                if self.taskDAO.items.isEmpty {
                    self.tableView.deleteSections(IndexSet([self.taskListSection]), with: .top)
                } else {
                    self.tableView.deleteRows(at: [indexPath], with: .top)
                }
            }
        }
        
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
        
        guard !isEmptyTrim(textQuickTask.text) else {
            return
        }
        
        let task = Task(context: taskDAO.context)
        task.name = sender.text
        
        sender.text = nil
        
        createTask(task)
        
        updateTable()
        
    }
    
    // добавить новую задачу
    func createTask(_ task:Task){
        taskDAO.add(task)
        
        attemptUpdate(task, forceUpdate: false, text: "Задача добавлена, но не показывается \nиз-за фильтра:")
        
    }
    
    // обновить задачу
    func updateTask(_ task:Task){
        taskDAO.update(task)
        
        attemptUpdate(task, forceUpdate: true, text: "Задача обновлена, но не показывается \nиз-за фильтра:")
        
        
    }
    
    // нужно обновлять таблицу или нет
    // Если новая/отредактированная задача не подпадает в текущий список (из-за фильтрации, поиска и пр.) - уведомить об этом пользователя (чтобы не паниковал, куда девалась  задача)
    // прогоняем через все условия фильтра (можно было реализовать по-простому с помощью  items.contains(task) - но если массив будет большим - возможны "подвисания")
    func attemptUpdate(_ task:Task, forceUpdate:Bool, text:String){ // forceUpdate - если в любом случае нужно обновить
        
        var willShow = true // задача будет отображаться в текущем списке
        
        var text = text // чтобы можно было изменять текст (т.к. параметр функции - константа)
        
        // чтобы не зависал UI - выполняем асинхронно
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            
            // если НЕ показываем заверешенные задачи, а у задачи статус "завершен"
            if !PrefsManager.current.showCompletedTasks && task.completed == true{
                willShow = false
            }
                
            else
                
                // если НЕ показываем задачи без категории, а у задачи пустая категория
                if !PrefsManager.current.showEmptyCategories && task.category == nil{
                    willShow = false
                    text = text + "\"НЕ показывать задачи с пустыми категорями\""
                }
                    
                else
                    
                    // если НЕ показываем задачи без приоритета, а у задачи пустой приоритет
                    if !PrefsManager.current.showEmptyPriorities && task.priority == nil{
                        willShow = false
                        text = text + "\"НЕ показывать задачи с пустыми приоритетами\""
                    }
                        
                    else
                        
                        // если НЕ показываем задачи без даты, а у задачи пустая дата
                        if !PrefsManager.current.showTasksWithoutDate && task.deadline == nil{
                            willShow = false
                            text = text + "\"НЕ показывать задачи без даты\""
                        }
                            
                            
                        else
                            
                            // если не проходит по фильтрации категорий
                            if let category = task.category, !self.categoryDAO.checkedItems().contains(category){
                                willShow = false
                                text = text + "\"НЕ показывать категорию \(category.name!)\""
                            }
                                
                            else
                                
                                // если не проходит по фильтрации приоритетов
                                if let priority = task.priority, !self.priorityDAO.checkedItems().contains(priority){
                                    willShow = false
                                    text = text + "\"НЕ показывать приоритет \(priority.name!)\""
                                    
                                }
                                    
                                    
                                else
                                    
                                    // если открыт поиск, а имя задачи не содержит текст поиска
                                    if (self.searchBarActive && task.name?.lowercased().range(of:self.searchBar.text!.lowercased()) == nil) {
                                        willShow = false
                                        text = text + "\"имя НЕ содержит \(self.searchBar.text!)\""
                                        
                                        
            }
            
            if willShow { // если задача должна показываться - обновляем таблицу
           
                self.updateTable()
            
            } else {
                
                if forceUpdate{ // если все равно надо обновить (например, при обновлении)
                    self.updateTable()
                }
                
                // уведомить пользователя о том, что задача не будет отображаться в текущем списке из-за фильтров
                Toast(text: text, delay: 0, duration: Delay.long).show()
                
            }
            
        }
        
    }
    
    
}




//MARK: ActionResultDelegate

extension TaskListController: ActionResultDelegate {
    
    // может обрабатывать ответы (слушать действия) от любых контроллеров
    func done(source: UIViewController, data: Any?) {
        
        // если пришел ответ от TaskDetailsController
        guard let controller = source as?  TaskDetailsController else{
            fatalError("fatal error with cell")
        }
        
        // сохраняет новую задачу или обновляет измененную задачу
        
        switch controller.mode {
        case .add?:
            let task = data as! Task
            
            createTask(task) // создаем новую задачу
        case .update?:
            let task = data as! Task
            
            updateTask(task) // обновляем  задачу
        default:
            return
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
    
    // начали редактировать текст поиска
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBarActive = true // есть также метод searchBar.isActive - но значение в него может быть записано позднее, чем это нужно нам, поэтому используем ручной способ - как только пользователь нажал на строку поиска - сохраняем true в переменную searchBarActive
    }
    
    // поиск после окончания ввода данных нажатия Найти
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        updateTable()
    }
    
    // при отмене поиска показываем все записи
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // при первом открытии и закрытии поиска на форме - активировать scope buttons (такой подход связан с глюком, когда компоненты налезают друг на друга при нажатии на Отмену)
        if !searchController.searchBar.showsScopeBar{
            searchController.searchBar.showsScopeBar = true
        }
        
        searchBarActive = false
        searchController.searchBar.text = ""
        
        updateTable() // обновить список задач согласно тексту поиска (если есть), сортировке и пр.
        
    }
    
    func setupSearchController() {
        
        searchController = UISearchController(searchResultsController: nil) // nil - отоброжение результата поиска в этом же view
        
        searchController.dimsBackgroundDuringPresentation = false // затемнять фон при поиске (затемненная область не доступна)
        
        definesPresentationContext = true // для правильного отображения внутри таблицы, без параметра может выходить поверх таблицы
        
        searchController.searchBar.placeholder = "Поиск по названию"
        searchController.searchBar.backgroundColor = .white
        
        // добавляем scope buttons
        searchController.searchBar.scopeButtonTitles = ["А-Я", "Приоритет", "Дата"]
        searchController.searchBar.selectedScopeButtonIndex = PrefsManager.current.sortType
        
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
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        if PrefsManager.current.sortType == selectedScope{ // если значение не изменилось (нажали уже активную кнопку) - ничего не делаем
            return
        }
        
        PrefsManager.current.sortType = selectedScope // сохраняем выбранный scope button (способ сортировки списка задач)
        
        updateTable() // обновить список задач согласно тексту поиска (если есть), сортировке и пр.
        
    }
    
    
}
