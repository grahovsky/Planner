//
//  CategoryListController.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class CategoryListController: DictonaryController<CategoryDaoDbImpl>{
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dictTableView = tableView
        DAO = CategoryDaoDbImpl.current
    }
    
    
    // MARK: @IBActions
    
    
    // закрытие контроллера без сохранения
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        
        cancel()
        
    }
    
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        save()
        
    }
    
    
    @IBAction func tapCheckCategory(_ sender: UIButton) {
        
        checkItem(sender)
        
    }
    
    // MARK: tableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as? CategoryListCell else { fatalError("fatal erroe with cell") }
        
        cell.selectionStyle = .none // чтобы не выделялась строка
        
        let category = DAO.items[indexPath.row]
        
        if selectedItem != nil && selectedItem == category {
            currentCheckedIndexPath = indexPath
            cell.buttonCheckCategory.setImage(UIImage(named: "check_green"), for: .normal)
        } else {
            cell.buttonCheckCategory.setImage(UIImage(named: "check_gray"), for: .normal)
        }
        
        cell.labelCategoryName.text = category.name
        
        return cell
        
    }
    
}
