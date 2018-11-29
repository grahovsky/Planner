//
//  TaskDAO.swift
//  Planner
//
//  Created by Konstantin on 28/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation

// общий протокол для поиска элементов
protocol CommonSearchDAO: Crud{
    
    func search(text:String) -> [Item]  // поиск по тексту
    
}
