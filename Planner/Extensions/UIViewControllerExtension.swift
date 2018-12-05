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
    
    func confirmAction(text: String, actionClosure: @escaping () -> Void) {
        
        // объект диалогового окна
        let dialogMessage = UIAlertController(title: "Подтверждение", message: text, preferredStyle: .actionSheet)
        
        // действие ок
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            actionClosure()
        }
        
        // действие отмена
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
       
        // добавить действия в диалоговое окно
        dialogMessage.addAction(okAction)
        dialogMessage.addAction(cancelAction)
        
        // показать диалоговое окно
        present(dialogMessage, animated: true, completion: nil)
        
    }
    
    // добавление кнопок Сохранить и Отмена (при выборе справочного значения)
    // Selector - это ссылка на какой-либо метод
    func createSaveCancelButtons(save: Selector, cancel: Selector = #selector(cancel)) { // по умолчанию - cancel
        
        // короткая запись создания кнопки
        // реализацию cancel передаем в параметре
        let buttonCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: cancel)
        navigationItem.leftBarButtonItem = buttonCancel
        
        // короткая запись создания кнопки
        // реализацию save передаем в параметре
        let buttonSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: save)
        navigationItem.rightBarButtonItem = buttonSave
        
    }
    
    // добавление кнопок Добавить и Закрыть (при выборе справочного значения)
    func createAddCloseButtons(add: Selector, close: Selector = #selector(cancel)) { // по умолчанию - cancel
        
        
        // полная запись создания кнопки
        let buttonClose = UIBarButtonItem()
        buttonClose.target = self
        buttonClose.action = close
        buttonClose.title = "Закрыть"
        navigationItem.leftBarButtonItem = buttonClose
        
 
        // короткая запись создания кнопки
        // реализацию save передаем в параметре
        let buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: add)
        navigationItem.rightBarButtonItem = buttonAdd
        
    }
    
    // по-умолчанию на cancel будет закрываться контроллер (если другой контроллер у себя не переопределит метод)
    @objc func cancel() {
        closeController()
    }
    
    // проверяет пустая строка или нет
    func isEmptyTrim(_ str: String?) -> Bool {
        if let value = str?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
            return false // не пусто
        } else {
            return true
        }
    }
    
}
