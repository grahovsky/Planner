//
//  TaskSearchDAO.swift
//  Planner
//
//  Created by Konstantin on 03/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation

// поиск задач с учетом фильтрации
protocol TaskSearchDAO: Crud {
    
    associatedtype CategoryItem: Category // любая реализация Category
    associatedtype PriorityItem: Priority // любая реализация Priority
    
    // поиск по тексту + фильтрация + сортировка
    func search(text: String?, categories: [CategoryItem], priorities: [PriorityItem], sortType: SortType?, showTasksEmptyCategories: Bool, showTasksEmptyPriorities: Bool, showTasksEmptyDates: Bool, showTasksCompleted: Bool) -> [Item]

}
