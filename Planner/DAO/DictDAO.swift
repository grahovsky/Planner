//
//  DictDAO.swift
//  Planner
//
//  Created by Konstantin on 17/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation
import CoreData

// справочные значения с возмоностью выделения элементов (для фильтрации задач или других целей)
protocol DictDAO: Crud where Item: Checkable {
    
    func checkedItems() -> [Item] // возвращает выделенные элементы, чтобы отфильтровать по ним список задач
    
}

extension DictDAO {
    
    // вернуть выбранные значения справочников (для сортировки списка задач)
    func checkedItems() -> [Item]{
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest() as! NSFetchRequest<Self.Item> // объект-контейнер для выборки данных
        
        // объект-контейнер для добавления условий
        var predicate = NSPredicate(format: "checked=true")
        
        fetchRequest.predicate = predicate // добавляем предикат в контейнер запроса
        
        var tmpItems:[Item]
        
        do {
            tmpItems = try context.fetch(fetchRequest) // выполняем запрос с предикатом
        } catch {
            fatalError("Fetching Failed")
        }
        
        return tmpItems
    }
    
}
