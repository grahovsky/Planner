//
//  AreaTapButton.swift
//  Planner
//
//  Created by Konstantin on 25/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

// кнопка с доп. областью для нажатия
class AreaTapButton: UIButton {

    // область кнопки будет немного больше, чем картинка (для удобства нажатия)
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let margin: CGFloat = 10 // доп. область вокруг кнопки
        let area = self.bounds.insetBy(dx: -margin, dy: -margin) // установка границ кнопки
        return area.contains(point)
        
    }

}
