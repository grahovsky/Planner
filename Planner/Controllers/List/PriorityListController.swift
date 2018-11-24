//
//  PriorityListController.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class PriorityListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let priorityDAO = PriorityDaoDbImpl.current
    
    var selectedPriority:Priority! // текущая категория задачи
    
    var currentCheckedIndexPath: IndexPath!
    
    var delegаte: ActionResultDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        priorityDAO.items.sort(by: { $0.index < $1.index })
    }

    // MARK: @IBActions
    
    
    // закрытие контроллера без сохранения
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        delegаte.done(source: self, data: selectedPriority)
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapCheckPriority(_ sender: UIButton) {
    
        // определяем индекс строки по нажатой кнопке в ячейке
        let viewPosition = sender.convert(CGPoint.zero, to: tableView) // координата относительно tableView
        let indexPath = self.tableView.indexPathForRow(at: viewPosition)!
        
        // определяем выбранную категорию
        let priority = priorityDAO.items[indexPath.row]
        
        if indexPath != currentCheckedIndexPath { // если текущая строка не была выделена
            
            selectedPriority = priority // сохраняем выбранную категорию
            
            if let currentCheckedIndexPath = currentCheckedIndexPath { // снимаем выделение с прошлой выбранной строки (т.к. selectedCategory - изменена
                tableView.reloadRows(at: [currentCheckedIndexPath], with: .none)
            }
            
        } else { // если строка была выделена - снимаем выделение
            
            selectedPriority = nil
            currentCheckedIndexPath = nil
            
        }
        
        // обновляем вид нажатой строки
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }
    
    
}

// MARK: tableView

extension PriorityListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priorityDAO.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellPriority", for: indexPath) as? PriorityListCell else { fatalError("fatal erroe with cell") }
        
        let priority = priorityDAO.items[indexPath.row]
        
        if selectedPriority != nil && selectedPriority == priority {
            cell.buttonCheckPriority.setImage(UIImage(named: "check_green"), for: .normal)
            currentCheckedIndexPath = indexPath
        } else {
            cell.buttonCheckPriority.setImage(UIImage(named: "check_gray"), for: .normal)
        }
        
        cell.labelPriorityName.text = priority.name
        
        return cell
        
    }
    
    
}
