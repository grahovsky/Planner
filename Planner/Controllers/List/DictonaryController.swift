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

    var buttonSelectDeselect: UIButton! // ссылка на фактическую кнопку для снятия/выделения
    
    var dictTableView: UITableView! // ссылка на компонент, нужно заполнять по факту уже из дочернего класса
    
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
                    dictTableView.reloadRows(at: [currentCheckedIndexPath], with: .none)
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
            updateItem(item)
            changed = true
            
        default:
            fatalError("enum type")
        }
        
        updateSelectDeselectButton()
        
        // обновляем вид нажатой строки (ставим галочку)
        dictTableView.reloadRows(at: [indexPath], with: .none)
        
        
    }
    
   func selectDeselectItems() {
    
        if DAO.checkedItems().count > 0 {
            DAO.items.map(){$0.checked = false}
        } else {
            DAO.items.map(){$0.checked = true}
        }
        
        dictTableView.reloadSections([sectionList], with: .none)
        
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
        
        if self.buttonSelectDeselect.title(for: .normal) != newTitle {
            buttonSelectDeselect.setTitle(newTitle, for: .normal)
        }
        
        var enabled: Bool
        
        if DAO.items.count > 1 {
            enabled = true
        } else {
            enabled = false
        }
        
        buttonSelectDeselect.isEnabled = enabled
        
        if !enabled {
            return
        }
        
    }
        
    
    func save() {
        
        closeController()
        delegаte?.done(source: self, data: selectedItem)
        
    }
    
    func add() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DAO.items.count
        
    }
    
    // обновляет значение в БД и списке
    func updateItem(_ item: T.Item) {
        
        // обновляем последний нажатый компонент
        if let selectedIndexPath = dictTableView.indexPathForSelectedRow {
            DAO.addOrUpdate(item)
            dictTableView.reloadRows(at: [selectedIndexPath], with: .none)
        }
        
    }
    
    func deleteItem(_ indexPath: IndexPath) {
        
        DAO.delete(DAO.items[indexPath.row])
        DAO.items.remove(at: indexPath.row) // удаляем из коллекции
        
        if DAO.items.count == 0 {
            dictTableView.deleteSections([sectionList], with: .left)
        } else {
            dictTableView.deleteRows(at: [indexPath], with: .left)
        }
        
        changed = true // оптимизация
        
    }
    
    /* последовательность действий (чтобы корректно работал компонент tableView):
     
     1) добавить запись в БД и в коллекцию
     2) если это первая запись - добавляем секцию (которая автоматически обновит свой контент и отобразит добавленную запись)
     если уже были записи - просто добавляем строку (секция уже существует, не нужно ее добавлять)
     */
    
    func addItem(_ item:T.Item){
        
        DAO.addOrUpdate(item)
        
        if DAO.items.count == 1 { // если добавляется первая запись - добавить сначала секции (в секции автоматически отбразится добавленная строка, не нужно делать insertRows)
            
            dictTableView.insertSections([sectionList] , with: .top)
            
        } else {
            
            // добавить новую строку с анимацией
            
            let indexPath = IndexPath(row: DAO.items.count-1, section: sectionList)
            
            dictTableView.insertRows(at: [indexPath], with: .top)
            
        }
        
        
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
    
    // этот метод должен реализовывать дочерний класс
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            dictTableView.tableHeaderView = searchBar
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !(searchBar.text?.isEmpty)!{ // искать, только если есть текст
            searchBarText = searchBar.text!
            search(searchBarText) // этот метод должен быть реализован в дочернем классе
            dictTableView.reloadData()  //  обновляем всю таблицу
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
        dictTableView.reloadData()
        searchBar.placeholder = "Начните набирать название"
    }
}

enum ShowMode {
    case edit // добавление, редактирование
    case select // выбор значения для задачи
}
