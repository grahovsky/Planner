//
//  FiltersController.swift
//  Planner
//
//  Created by Konstantin on 02/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

// контроллер для фильтрации задач
class FiltersController: UITableViewController {

    @IBOutlet weak var switchEmptyPriorities: UISwitch!
    @IBOutlet weak var switchEmptyCategories: UISwitch!
    @IBOutlet weak var switchEmptyDates: UISwitch!
    @IBOutlet weak var switchCompleted: UISwitch!
    
    let filterSection = 0
    
    var initState: (Bool, Bool, Bool, Bool)!
    
    var changed:Bool {
        return initState != (PrefsManager.current.showEmptyCategories, PrefsManager.current.showEmptyPriorities, PrefsManager.current.showTasksWithoutDate, PrefsManager.current.showCompletedTasks)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchEmptyCategories.isOn = PrefsManager.current.showEmptyCategories
        switchEmptyPriorities.isOn = PrefsManager.current.showEmptyPriorities
        switchEmptyDates.isOn = PrefsManager.current.showTasksWithoutDate
        switchCompleted.isOn = PrefsManager.current.showCompletedTasks
        
        initState = (PrefsManager.current.showEmptyCategories, PrefsManager.current.showEmptyPriorities, PrefsManager.current.showTasksWithoutDate, PrefsManager.current.showCompletedTasks)
    }

    // MARK: - Table view


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
   // MARK: actions
    
    @IBAction func switchedEmptyPriorities(_ sender: UISwitch) {
        PrefsManager.current.showEmptyPriorities = sender.isOn // считаем значение switch (true, false)
    }
    
    @IBAction func switchedEmptyCategories(_ sender: UISwitch) {
        PrefsManager.current.showEmptyCategories = sender.isOn
    }

    @IBAction func switchedEmptyDates(_ sender: UISwitch) {
        PrefsManager.current.showTasksWithoutDate = sender.isOn
    }
    
    @IBAction func switchedCompleted(_ sender: UISwitch) {
        PrefsManager.current.showCompletedTasks = sender.isOn
    }
 
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == filterSection {
            return "Выберите значения"
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
