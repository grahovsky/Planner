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

extension UITextView{
    
    // ищет URL ссылку при нажатии в текстовом поле, если нашел - открывает ее в браузере
    func findUrl(sender: UITapGestureRecognizer) -> Bool{
        
        let textView = self
        let tapLocation = sender.location(in: textView)
        let textPosition = textView.closestPosition(to:tapLocation)
        let attr: NSDictionary = textView.textStyling(at:textPosition!, in: UITextStorageDirection.forward)! as NSDictionary
        
        // если нажали на URL в тексте - открыть в браузере системы
        if let url: NSURL = attr[NSAttributedString.Key.link] as? NSURL {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
            
            return true
        }
        
        return false
        
    }
    
}

