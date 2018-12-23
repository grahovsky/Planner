//
//  Checkable.swift
//  Planner
//
//  Created by Konstantin on 17/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation

// используется для полиморфизма в универсальном контроллере DictonaryController
protocol Checkable: class { // только класс (не struct) сможет использовать этот протокол (иначе может возникнуть ошибка immutable при попытке записать значение в checked
    
    var checked: Bool {get set} // выделено значение или нет (только для фильтрации)
    
}

// protocol adoption (не можем редактировать сам класс, но можем адаптировать его в нужные протоколы)
extension Priority: Checkable {
    
}

extension Category: Checkable {
    
}
