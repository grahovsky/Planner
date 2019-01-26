//
//  SideMenuController.swift
//  Planner
//
//  Created by Konstantin on 02/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class SideMenuController: UITableViewController {
    
    
    @IBOutlet weak var cellFeedback: UITableViewCell!
    @IBOutlet weak var cellShare: UITableViewCell!
    
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
    
    // действия при нажатии на пункты меню
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.isUserInteractionEnabled = false // защита от двойных нажатий (при новом показе контроллера значение isUserInteractionEnabled будет true)
        
        // if tableView.cellForRow(at: indexPath) === cellFeedback // === - проверка на соответствие элементов
        
        let changedCell = tableView.cellForRow(at: indexPath)
        
        switch changedCell {
        case cellFeedback:
            // "Написать разработчику"
            let email = "grahovsky@gmail.com" // TODO: вынести адрес в plist
            if let url = URL(string: "mailto:\(email)") {
                UIApplication.shared.open(url)
            }
        case cellShare:
            // "Поделиться"
            let shareController = UIActivityViewController(activityItems: ["Пользуйтесь Planner"], applicationActivities: nil)
            
            shareController.popoverPresentationController?.sourceView = self.view
            
            present(shareController, animated: true, completion: nil)
        default:
            break
        }
        
        tableView.isUserInteractionEnabled = true // возвращаем возможность нажимать на таблицу (требовалось для защиты от двойных нажатий)
        
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
        case "EditPriorities":
            guard let controller = segue.destination as? PriorityListController else { return }
            
            controller.showMode = .edit
            controller.navigationTitle = "Редактирование"
            
        default:
            return
        }
        
        
    }
    
    
}
