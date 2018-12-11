//
//  SideMenuController.swift
//  Planner
//
//  Created by Konstantin on 02/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class SideMenuController: UITableViewController {

    let commonSection = 0
    let dictionarySection = 1
    let helpSection = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.backgroundColor = .darkGray
        
    }

    // MARK: - Table view
    
    
    // цвета для шапок в каждой секции
    override func tableView(_ tableView: UITableView, willDisplayHeaderView
        view: UIView, forSection section: Int) {
        
        
        // стили для отоброжения
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = .darkGray
        header.textLabel?.textColor = .lightGray
        
    }
    
    // цвета для футеров в каждой секции
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = .darkGray
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case commonSection:
            return "Общие"
        case dictionarySection:
            return "Справочники"
        case helpSection:
            return "Помощь"
        default:
            return ""
        }
        
    }
    
    // высота секций
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // высота футеров
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 40
        
    }
    
    // высота строк
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 40
        
    }
    
    
    // MARK: prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == nil {
            return
        }
        
        switch segue.identifier! {
        case "EditCategories":
            guard let controller = segue.destination as? CategoryListController else { return }
            
            controller.showMode = .edit
            controller.navigationTitle = "Редактирование"
            
        default:
            return
        }
        
        
    }


}
