//
//  QuickTaskCell.swift
//  Planner
//
//  Created by Konstantin on 27/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class QuickTaskCell: UITableViewCell {

    
    @IBOutlet weak var textQuickTask: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textQuickTask.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension QuickTaskCell: UITextFieldDelegate {
    
    // при нажатии Enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textQuickTask.resignFirstResponder() // скрыть фокус с текстового поля (клавиатура исчезнет)
        return true
    }
    
}
