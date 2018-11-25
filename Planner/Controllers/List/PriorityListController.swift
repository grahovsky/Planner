//
//  PriorityListController.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class PriorityListController: DictonaryController<PriorityDaoDbImpl> {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view.
        dictTableView = tableView
        DAO = PriorityDaoDbImpl.current
        
        DAO.items.sort(by: { $0.index < $1.index })
    }
    
    // MARK: @IBActions
    
    
    // закрытие контроллера без сохранения
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        
        cancel()
        
    }
    
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        save()
        
    }
    
    @IBAction func tapCheckPriority(_ sender: UIButton) {
        
        checkItem(sender)
        
    }
    
    
    // MARK: tableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellPriority", for: indexPath) as? PriorityListCell else { fatalError("fatal erroe with cell") }
        
        cell.selectionStyle = .none // чтобы не выделялась строка
        
        let priority = DAO.items[indexPath.row]
        
        if selectedItem != nil && selectedItem == priority {
            cell.buttonCheckPriority.setImage(UIImage(named: "check_green"), for: .normal)
            currentCheckedIndexPath = indexPath
        } else {
            cell.buttonCheckPriority.setImage(UIImage(named: "check_gray"), for: .normal)
        }
        
        cell.labelPriorityName.text = priority.name
        
        return cell
        
    }
    
    
}
