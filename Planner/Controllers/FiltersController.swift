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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    }
    
    @IBAction func switchedEmptyCategories(_ sender: UISwitch) {
    }

    @IBAction func switchedEmptyDates(_ sender: UISwitch) {
    }
    
    @IBAction func switchedCompleted(_ sender: UISwitch) {
    }
    
    
    
    
    

}
