//
//  PriorityListController.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class PriorityListController: UIViewController {

    let priorityDAO = PriorityDaoDbImpl.current
    
    var selectedPriority:Priority! // текущая категория задачи
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        priorityDAO.items.sort(by: { $0.index < $1.index })
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
        } else {
            cell.buttonCheckPriority.setImage(UIImage(named: "check_gray"), for: .normal)
        }
        
        cell.labelPriorityName.text = priority.name
        
        return cell
        
    }
    
    
}
