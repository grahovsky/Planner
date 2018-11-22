//
//  CrudExtension.swift
//  Planner
//
//  Created by Konstantin on 22/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import CoreData
import UIKit
import Foundation

extension Crud {
    
    var context:NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // контекст для работы с БД
    }
    
    // сохранение всех изменений контекста
    func save(){
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
}
