//
//  SideMenuCell.swift
//  Planner
//
//  Created by Konstantin on 02/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // фон для ячейки при инициализации
    // @IBInspectable - можно будет задавать настройку через IB
    @IBInspectable var selectionColor: UIColor = .gray {
        
        didSet {
            setBackgroud()
        }
        
    }
    
    // создает вью и делает его фоном для ячейки
    private func setBackgroud() {
        
        let view = UIView()
        view.backgroundColor = selectionColor
        selectedBackgroundView = view
        
    }

}
