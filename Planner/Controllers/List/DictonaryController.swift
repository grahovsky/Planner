//
//  DictonaryController.swift
//  Planner
//
//  Created by Konstantin on 25/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

// общий класс для контроллеров по работе со справочными значениями (в данный момент: категории, приоритеты)
// процесс заполнения таблиц будет реализовываться в дочерних классах, в данном классе - весь общий функционал
class DictonaryController<T:DictDAO>: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    var labelHeaderTitleDict:UILabel! // ссылка на фактическую кнопку для выделения/снятия
    
    var buttonSelectDeselectDict:UIButton! // ссылка на фактическую кнопку для выделения/снятия
    
    var tableViewDict: UITableView! // ссылка на компонент, нужно заполнять по факту уже из дочернего класса
    
    var DAO:T! // DAO для работы с БД (для каждого справочника будет использоваться своя реализация DAO)
    
    var selectedItem: T.Item! // текущий выбранный элемент
    
    var currentCheckedIndexPath: IndexPath! // индекс последнего/текущего выделенного элемента
    
    var delegаte: ActionResultDelegate! // для передачи выбранного элемента обратно в контроллер
    
    var searchController: UISearchController! // поисковый элемент, который будет добавляться поверх таблицы задач
    
    var searchBarText:String! // текущий текст для поиска
    
    var navigationTitle: String!
    
    // для сокращения кода
    var searchBar: UISearchBar {
        return searchController.searchBar
    }
    
    let sectionList = 0
    
    var showMode: ShowMode!
    
    // для сокращения кода (необязательно)
    var count:Int {
        return DAO.items.count
    }
    
    var initState: (Bool, Bool, Bool, Bool)!
    
    var changed = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupSearchController()
        searchController.searchBar.searchBarStyle = .prominent
        
    }
    
    // создать нужные кнопки в панели навигации (в зависимости от режима отображения showMode)
    func initNavBar() {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // в данном режиме разрешаем выбирать только одну строку
        if showMode == .select {
            // в параметрах передаем функции, которые будут вызываться по нажатию на кнопки
            createSaveCancelButtons(save: #selector(tapSave), cancel: #selector(tapCancel))
        } else if showMode == .edit {
            
            createAddCloseButtons(add: #selector(tapAdd), close: #selector(tapClose))
            
        }
        
        self.title = navigationTitle // название меняется в зависимости от типа действий (редактирование, выбор для задачи)
        
        // для переноса текста на новую строку (если не будет помещаться)
        labelHeaderTitleDict.lineBreakMode = .byWordWrapping
        labelHeaderTitleDict.numberOfLines = 0
        labelHeaderTitleDict.textColor = UIColor.lightGray
        
    }
    
    
    // удаление строки
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteItem(indexPath)
        } else if editingStyle == .insert {
            //create new instance
        }
        
    }
    
    func checkItem(_ indexPath: IndexPath) {
        
        let item = DAO.items[indexPath.row]
        
        switch showMode! {
        case .select:
            if indexPath != currentCheckedIndexPath {
                selectedItem = item
                
                if let currentCheckedIndexPath = currentCheckedIndexPath {
                    tableViewDict.reloadRows(at: [currentCheckedIndexPath], with: .none)
                }
                
                currentCheckedIndexPath = indexPath
                
            } else {
                selectedItem = nil
                currentCheckedIndexPath = nil
            }
            
            // если пользователь выбрал значение - закрывать поисковое окно
            searchController.isActive = false
            
        case .edit:
            
            item.checked = !item.checked
            updateItem(item, indexPath: indexPath)
            changed = true
            
        default:
            fatalError("enum type")
        }
        
        updateSelectDeselectButton()
        
        // обновляем вид нажатой строки (ставим галочку)
        tableViewDict.reloadRows(at: [indexPath], with: .none)
        
        
    }
    
   func selectDeselectItems() {
    
        if DAO.checkedItems().count > 0 {
            DAO.items.map(){$0.checked = false}
        } else {
            DAO.items.map(){$0.checked = true}
        }
        
        tableViewDict.reloadSections([sectionList], with: .none)
        
        updateSelectDeselectButton()
        
        changed = true
    
    }
    
    
    
    func updateSelectDeselectButton() {
        
        if showMode == .select {
            return
        }
        
        let newTitle: String
        
        if DAO.checkedItems().count > 0 {
            newTitle = "Снять"
        } else {
            newTitle = "Все"
        }
        
        if self.buttonSelectDeselectDict.title(for: .normal) != newTitle {
            buttonSelectDeselectDict.setTitle(newTitle, for: .normal)
        }
        
        var enabled: Bool
        
        if DAO.items.count > 1 {
            enabled = true
        } else {
            enabled = false
        }
        
        buttonSelectDeselectDict.isEnabled = enabled
        
        if !enabled {
            return
        }
        
    }
        
    
    func save() {
        
        closeController()
        delegаte?.done(source: self, data: selectedItem)
        
    }
    
    func add() {
        addItemAction()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DAO.items.count
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        updateTableBackground(tableViewDict, count:count)
        
        if count == 0 {
            
            // скрыть компоненты для выделения
            labelHeaderTitleDict.isHidden = true
            buttonSelectDeselectDict.isHidden = true
            return 0 // пустая таблица, без записей
        }
        
        // если есть данные - показывать контролы
        labelHeaderTitleDict.isHidden = false
        buttonSelectDeselectDict.isHidden = false
        
        
        return 1 // секция со списком значений
        
    }
    
    // обновляет значение в БД и списке
    func updateItem(_ item: T.Item, indexPath: IndexPath) {
        
        DAO.addOrUpdate(item)
        tableViewDict.reloadRows(at: [indexPath], with: .none)
        
    }
    
    func deleteItem(_ indexPath: IndexPath) {
        
        DAO.delete(DAO.items[indexPath.row])
        DAO.items.remove(at: indexPath.row) // удаляем из коллекции
        
        if DAO.items.count == 0 {
            tableViewDict.deleteSections([sectionList], with: .left)
        } else {
            tableViewDict.deleteRows(at: [indexPath], with: .left)
        }
        
        changed = true // оптимизация
        
        updateTableBackground(tableViewDict, count: DAO.items.count)
        
    }
    
    /* последовательность действий (чтобы корректно работал компонент tableView):
     
     1) добавить запись в БД и в коллекцию
     2) если это первая запись - добавляем секцию (которая автоматически обновит свой контент и отобразит добавленную запись)
     если уже были записи - просто добавляем строку (секция уже существует, не нужно ее добавлять)
     */
    
    func addItem(_ item:T.Item){
        
        DAO.add(item)
        
        if count == 1 { // если добавляется первая запись - добавить сначала секции (в секции автоматически отбразится добавленная строка, не нужно делать insertRows)
            
            tableViewDict.insertSections([sectionList] , with: .top)
            
        } else {
            
            // добавить новую строку с анимацией
            
            let indexPath = IndexPath(row: count-1, section: sectionList)
            
            tableViewDict.insertRows(at: [indexPath], with: .top)
            
        }
        
        updateSelectDeselectButton()
        
        updateTableBackground(tableViewDict, count:count)
        
    }
    
    
    // MARK: #selectors
    
    // два действия при редактировании
    @objc private func tapClose() {
        
        switch self {
        case is CategoryListController:
            performSegue(withIdentifier: "UpdateTasksCategories", sender: self)
            
        case is PriorityListController:
            performSegue(withIdentifier: "UpdateTasksPriorities", sender: self)
            
        default:
            return
        }
        
    }
    
    @objc private func tapAdd() {
        add()
    }
    
    
    // два действия при выборе справочного значения для задачи
    @objc private func tapSave() {
        save()
    }
    
    @objc private func tapCancel() {
        cancel()
    }
    
    
    // MARK: must implemented
    
    // получение всех объектов с сортировкой
    func getAll() -> [T.Item]{
        fatalError("not implemented")
    }
    
    // поиск объектов с сортировкой
    func search(_ text:String) -> [T.Item]{
        fatalError("not implemented")
    }
    
    // этот метод должен реализовывать дочерний класс
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("not implemented")
    }
    
    // нажатие на строку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if showMode == .edit {
            editItemAction(indexPath: indexPath) // в режиме edit - переходим к редактированию
            return
        }
        
        if showMode == .select {
            checkItem(indexPath) // в режиме select - выбираем элемент (для задачи)
            return
        }
        
    }
    
    // добавление нового элемента
    func addItemAction(){
        fatalError("not implemented")
    }
    
    // редактирование
    func editItemAction(indexPath:IndexPath){
        fatalError("not implemented")
    }
    
    //MARK: search
    
    func setupSearchController() {
        
        searchController = UISearchController(searchResultsController: nil) // nil - отоброжение результата поиска в этом же view
        
        searchController.dimsBackgroundDuringPresentation = false // затемнять фон при поиске (затемненная область не доступна)
        
        definesPresentationContext = true // для правильного отображения внутри таблицы, без параметра может выходить поверх таблицы
        
        searchBar.placeholder = "Начните вводить название"
        searchBar.backgroundColor = .white
        
        searchController.searchResultsUpdater = self
        searchBar.delegate = self
        
        searchBar.showsScopeBar = false // чтобы не показывалось ничего под строкой поиска
        
        searchBar.showsCancelButton = false
        searchBar.setShowsCancelButton(false, animated: false)
        
        searchBar.searchBarStyle = .minimal
        
        searchController.hidesNavigationBarDuringPresentation = false // закрытие navigaton bar компонентом поиска
        
        // из-за особенностей реализации от версии iOS
        if #available(iOS 11.0, *) { // для iOS 11 и выше
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableViewDict.tableHeaderView = searchBar
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !(searchBar.text?.isEmpty)!{ // искать, только если есть текст
            searchBarText = searchBar.text!
            search(searchBarText) // этот метод должен быть реализован в дочернем классе
            tableViewDict.reloadData()  //  обновляем всю таблицу
            currentCheckedIndexPath = nil // чтобы не было двойного выделения значений
            searchBar.placeholder = searchBarText // сохраняем поисковый текст для отображения, если окно поиска будет неактивным
        }
    }
    
    // обязательно нажать Найти для поиска
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return false
    }
    
    // поиск после окончания ввода данных нажатия Найти
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        if !(searchController.searchBar.text?.isEmpty)! { // искать только если есть текст
//            DAO.search(text: searchController.searchBar.text!)
//            dictTableView.reloadData()
//        }
    }
    
    // при отмене поиска показываем все записи
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarText = ""
        getAll() // этот метод должен быть реализован в дочернем классе
        tableViewDict.reloadData()
        searchBar.placeholder = "Начните набирать название"
    }
}

enum ShowMode {
    case edit // добавление, редактирование
    case select // выбор значения для задачи
}
