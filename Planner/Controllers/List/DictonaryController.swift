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
class DictonaryController<T:CommonSearchDAO>: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {

    var dictTableView: UITableView! // ссылка на компонент, нужно заполнять по факту уже из дочернего класса
    
    var DAO:T! // DAO для работы с БД (для каждого справочника будет использоваться своя реализация DAO)
    
    var selectedItem: T.Item! // текущий выбранный элемент
    
    var currentCheckedIndexPath: IndexPath! // индекс последнего/текущего выделенного элемента
    
    var delegаte: ActionResultDelegate! // для передачи выбранного элемента обратно в контроллер
    
    var searchController: UISearchController! // поисковый элемент, который будет добавляться поверх таблицы задач
    
    var searchBarText:String! // текущий текст для поиска
    
    // для сокращения кода
    var searchBar: UISearchBar {
        return searchController.searchBar
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupSearchController()
        searchController.searchBar.searchBarStyle = .prominent
        
    }
    
    
    func checkItem(_ sender: UIView) {
        
        // определяем индекс строки по нажатой кнопке в ячейке
        let viewPosition = sender.convert(CGPoint.zero, to: dictTableView) // координата относительно tableView
        let indexPath = dictTableView.indexPathForRow(at: viewPosition)!
        
        let item = DAO.items[indexPath.row]
        
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
        
        // обновляем вид нажатой строки
        dictTableView.reloadRows(at: [indexPath], with: .none)
        
        // если пользователь выбрал значение - закрывать поисковое окно
        searchController.isActive = false
        
    }
    
    func cancel() {
        
        closeController()
        
    }
    
    func save() {
        
        closeController()
        delegаte.done(source: self, data: selectedItem)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DAO.items.count
        
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
