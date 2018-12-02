//
//  UIViewControllerExtension.swift
//  Planner
//
//  Created by Konstantin on 01/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func createDateFormatter() -> DateFormatter {
        
        let dateFormatter = DateFormatter();
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        return dateFormatter
                
    }
    
    func closeController() {
        
        if presentingViewController is UINavigationController {
            dismiss(animated: true, completion: nil)
        } else if let controller = navigationController {
            controller.popViewController(animated: true)
        } else {
            fatalError("can't close controller")
        }
    
    }
    
    func handleDeadline(label: UILabel, data: Date?) {
        
        label.text = ""
        label.textColor = UIColor.lightGray
        
        if let data = data {
           
            label.textColor = UIColor.black
            
            let diff = data.offsetFrom(date: Date().today)
            
            switch diff {
            case 0:
                label.text = "Сегодня" // TODO: локализация
            case 1:
                label.text = "Завтра"
            case 0...:
                label.text = "\(diff) дн."
            case ..<0:
                label.textColor = .red
                label.text = "\(diff) дн."
            default:
                break
            }
            
        }
        
        
    }
    
    
}
