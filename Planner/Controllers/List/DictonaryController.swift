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
class DictonaryController<T:Crud>: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var dictTableView: UITableView! // ссылка на компонент, нужно заполнять по факту уже из дочернего класса
    
    var DAO:T! // DAO для работы с БД (для каждого справочника будет использоваться своя реализация DAO)
    
    var selectedItem: T.Item! // текущий выбранный элемент
    
    var currentCheckedIndexPath: IndexPath! // индекс последнего/текущего выделенного элемента
    
    var delegаte: ActionResultDelegate! // для передачи выбранного элемента обратно в контроллер
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
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
        
    }
    
    func cancel() {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    func save() {
        
        cancel()
        delegаte.done(source: self, data: selectedItem)
        
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DAO.items.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        fatalError("not implemented") //обязательно override
        
    }
    
}
