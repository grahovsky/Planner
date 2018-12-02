//
//  TaskInfoController.swift
//  Planner
//
//  Created by Konstantin on 25/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class TaskInfoController: UIViewController {

    @IBOutlet weak var textViewTaskInfo: UITextView!
    
    var taskInfo: String! // текущий измененный текст

    var delegаte: ActionResultDelegate! // для передачи выбранного элемента обратно в контроллер
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Доп. инфо"
        
        // фокусируемся на компоненте для открытия клавиатуры
        textViewTaskInfo.becomeFirstResponder()
        
        textViewTaskInfo.text = taskInfo
    
    }
    
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        
        closeController()
    
    }
    
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        closeController()
        delegаte.done(source: self, data: textViewTaskInfo.text)
    
    }
    
    
}
