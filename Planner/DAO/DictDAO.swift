//
//  DictDAO.swift
//  Planner
//
//  Created by Konstantin on 17/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation

// справочные значения с возмоностью выделения элементов (для фильтрации задач или других целей)
protocol DictDAO: Crud where Item: Checkable {
    
    func checkedItems() -> [Item] // возвращает выделенные элементы, чтобы отфильтровать по ним список задач
    
}

extension DictDAO {
    
    // все выделенные элементы из коллекции
    func checkedItems() -> [Item]{
        return items.filter(){$0.checked == true}
    }
    
}
