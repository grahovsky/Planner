//
//  CategoryListCell.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class CategoryListCell: UITableViewCell {

    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var buttonCheckCategory: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
