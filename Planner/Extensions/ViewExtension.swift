//
//  ViewExtension.swift
//  Planner
//
//  Created by Konstantin on 25/01/2019.
//  Copyright © 2019 Tim. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func roundLabel() {
        // Initialization code
        
        self.layer.cornerRadius = 12 // в IB указали высоту и ширину 24, радиус пополам
        self.layer.backgroundColor = UIColor(named: "separator")?.cgColor
        self.textAlignment = .center // выравнивание текста
        self.textColor = .darkGray
    }
    
}

