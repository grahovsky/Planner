//
//  PrefsManager.swift
//  Planner
//
//  Created by Konstantin on 03/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation

class PrefsManager {
    
    static let current = PrefsManager()
    
    private init() {
        
        // создать ключи для хранения значений настроек (только при первом запуске)
        UserDefaults.standard.register(defaults: ["showEmptyCategories" : true])
        UserDefaults.standard.register(defaults: ["showEmptyPriorities" : true])
        UserDefaults.standard.register(defaults: ["showEmptyDates" : true])
        UserDefaults.standard.register(defaults: ["showCompleted" : true])
        UserDefaults.standard.register(defaults: ["selectedScope" : 0])
        //UserDefaults.standard.register(defaults: ["filterUpdate" : false])
        
    }
    
    // MARK: filter settings
    
    // показать или нет в общем списке задачи, у которых не были указаны категории
    var showEmptyCategories: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "showEmptyCategories")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showEmptyCategories")
        }
    }
    
    // показать или нет в общем списке задачи, у которых не были указаны приоритеты
    var showEmptyPriorities: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "showEmptyPriorities")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showEmptyPriorities")
        }
    }
    
    // показать или нет в общем списке задачи, у которых не были указаны приоритеты
    var showEmptyDates: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "showEmptyDates")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showEmptyDates")
        }
    }
    
    // показать или нет в общем списке задачи, у которых не были указаны приоритеты
    var showCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "showCompleted")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showCompleted")
        }
    }
    
    var selectedScope: Int {
        get {
            return UserDefaults.standard.integer(forKey: "selectedScope")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedScope")
        }
    }
    
//    var filterUpdate: Bool {
//        get {
//            return UserDefaults.standard.bool(forKey: "filterUpdate")
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: "filterUpdate")
//        }
//    }
    
}
