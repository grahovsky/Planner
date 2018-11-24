//
//  ActionResultsDelegate.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation
import UIKit

// для уведомления другого контроллера о своем действии и передача объекта (если необходимо)
protocol ActionResultDelegate {
    
    func done(source: UIViewController, data: Any?)  // Ок, сохранить
    
    func cancel(source: UIViewController, data: Any?)  // отмена действия
    
}

// реализации по-умолчанию для протокола
extension ActionResultDelegate {

//    func done(source: UIViewController, data: Any?) {
//        fatalError("not implemented")
//    }
//    
//    func cancel(source: UIViewController, data: Any?) {
//        fatalError("not implemented")
//    }
    
}

