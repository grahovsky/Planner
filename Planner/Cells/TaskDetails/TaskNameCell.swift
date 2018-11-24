//
//  TaskNameCellTableViewCell.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class TaskNameCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textTaskName: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textTaskName.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // при нажатии Enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textTaskName.resignFirstResponder() // скрыть фокус с текстового поля (клавиатура исчезнет)
        return true
    }

}
