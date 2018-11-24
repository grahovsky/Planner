//
//  CategoryListController.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class CategoryListController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let categoryDAO = CategoryDaoDbImpl.current
    
    var selectedCategory: Category! // текущая категория задачи
    
    var currentCheckedIndexPath: IndexPath!
    
    var delegаte: ActionResultDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    
    // MARK: @IBActions
    
    
    // закрытие контроллера без сохранения
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
             
        delegаte.done(source: self, data: selectedCategory)
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
    
    @IBAction func tapCheckCategory(_ sender: UIButton) {
        
        // определяем индекс строки по нажатой кнопке в ячейке
        let viewPosition = sender.convert(CGPoint.zero, to: tableView) // координата относительно tableView
        let indexPath = self.tableView.indexPathForRow(at: viewPosition)!
        
        // определяем выбранную категорию
        let category = categoryDAO.items[indexPath.row]
        
        if indexPath != currentCheckedIndexPath { // если текущая строка не была выделена
            
            selectedCategory = category // сохраняем выбранную категорию
            
            if let currentCheckedIndexPath = currentCheckedIndexPath { // снимаем выделение с прошлой выбранной строки (т.к. selectedCategory - изменена
                tableView.reloadRows(at: [currentCheckedIndexPath], with: .none)
            }
            
        } else { // если строка была выделена - снимаем выделение
            
            selectedCategory = nil
            currentCheckedIndexPath = nil
            
        }
        
        // обновляем вид нажатой строки 
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }
    
}

// MARK: tableView

extension CategoryListController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryDAO.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as? CategoryListCell else { fatalError("fatal erroe with cell") }
        
        let category = categoryDAO.items[indexPath.row]
        
        if selectedCategory != nil && selectedCategory == category {
            currentCheckedIndexPath = indexPath
            cell.buttonCheckCategory.setImage(UIImage(named: "check_green"), for: .normal)
        } else {
            cell.buttonCheckCategory.setImage(UIImage(named: "check_gray"), for: .normal)
        }
        
        cell.labelCategoryName.text = category.name
        
        return cell
        
    }
    
    
}
