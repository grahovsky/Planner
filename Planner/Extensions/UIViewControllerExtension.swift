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
                label.text = lsToday
            case 1:
                label.text = lsTomorrow
            case 0...:
                label.text = "\(diff) \(lsDays)."
            case ..<0:
                label.textColor = .red
                label.text = "\(diff) \(lsDays)."
            default:
                break
            }
            
        }
        
        
    }
    
    func confirmAction(text: String, actionClosure: @escaping () -> Void) {
        
        // объект диалогового окна
        let dialogMessage = UIAlertController(title: lsConfirm, message: text, preferredStyle: .actionSheet)
        
        // действие ок
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            actionClosure()
        }
        
        // действие отмена
        let cancelAction = UIAlertAction(title: lsCancel, style: .cancel, handler: nil)
       
        // добавить действия в диалоговое окно
        dialogMessage.addAction(okAction)
        dialogMessage.addAction(cancelAction)
        
        // показать диалоговое окно
        present(dialogMessage, animated: true, completion: nil)
        
    }
    
    func showDialog(title: String, message: String, initValue: String = "", actionClosure: @escaping (String)->Void) {
        
        // запускаем асинхронно, чтобы не было задержки при показе диалогового окна, если открыть диалоговое окно в главном потоке - могут быть лаги - окно не сразу показывается
        DispatchQueue.main.async {
            
            // показываем диалоговое окно с текстовым компонентом для редактирования названия
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            // добавляем текстовое поле в диалоговое окно
            alert.addTextField(configurationHandler: nil)
            
            //кнопка очистки
            alert.textFields?[0].clearButtonMode = .whileEditing //кнопка очистки
            
            alert.textFields?[0].text = initValue
            
            // добавляем действие для кнопки ОК
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                actionClosure(alert.textFields?[0].text ?? "")
                
            }))
            
            // при нажатии на Cancel - ничего не делаем (окно закроется само)
            alert.addAction(UIAlertAction(title: lsCancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil) // показать диалоговое окно с анимацией появления
            
        }
        
        
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
        buttonClose.title = lsClose
        navigationItem.leftBarButtonItem = buttonClose
        
 
        // короткая запись создания кнопки
        // реализацию save передаем в параметре
        let buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: add)
        navigationItem.rightBarButtonItem = buttonAdd
        
    }
    
    // добавляет только 1 кнопку - Закрыть
    func createCloseButtonOnly(close: Selector = #selector(cancel)){ // если не передавать параметр - по-умолчанию будет вызываться cancel
        
        let buttonClose = UIBarButtonItem()
        buttonClose.target = self
        buttonClose.action = close
        buttonClose.title = lsClose
        navigationItem.leftBarButtonItem = buttonClose
        
        navigationItem.rightBarButtonItem = nil
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
    
    // если нажали мимо клавиатуры - скрывать ее
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // сообщение, если нет данных
    func createNoDateView(_ text:String) -> UILabel {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        messageLabel.text = text
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textColor = .darkGray
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        
        return messageLabel
    }
    
    //обновляет фон для таблицы, если нет данных
    func updateTableBackground(_ tableView: UITableView, count: Int) {
        if count > 0 {
            tableView.separatorColor = UIColor(named: "separator") // цвет будет браться из assets
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        } else {
            tableView.separatorStyle = .none //чтобы не было пустых линий
            tableView.backgroundView = createNoDateView(lsNoData) // показать сообщение, что нет данных в таблице
        }
    }

}
