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
    
    var taskInfoShowMode:TaskInfoShowMode!
    
    var navigationTitle:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = navigationTitle
        
        textViewTaskInfo.text = taskInfo
        // Do any additional setup after loading the view.
        
        switch taskInfoShowMode {
        case .readOnly?:
            textViewTaskInfo.isEditable = false
            
            // добавляем возможность обрабатывать нажатие на текстовое поле
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: textViewTaskInfo, action:    #selector(tapTextView(_:))) // передается ссылка на созданный UITapGestureRecognizer, чтобы далее определить, в каком месте нажали
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
            
            
        case .edit?:
            
            textViewTaskInfo.isEditable = true
            createSaveCancelButtons(save: #selector(tapSave))
            textViewTaskInfo.becomeFirstResponder() // сразу даем редактировать и показываем клавиатуру
            
        default:
            return
        }
    
    }
    
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        
        closeController()
    
    }
    
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        closeController()
        delegаte.done(source: self, data: textViewTaskInfo.text)
    
    }
    
    @objc func tapTextView(_ sender: UITapGestureRecognizer){
        textViewTaskInfo.findUrl(sender: sender) // ищет url при нажатии на текстовый компонента
    }
    
}

// режимы работы
enum TaskInfoShowMode{
    case readOnly // добавление, редактирование
    case edit // выбор значения для задачи
}
