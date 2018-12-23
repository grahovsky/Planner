//
//  PriorityListController.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class PriorityListController: DictonaryController<PriorityDaoDbImpl> {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelHeaderTitle: UILabel!    
    @IBOutlet weak var buttonSelectDeselectAll: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        super.buttonSelectDeselect = buttonSelectDeselectAll
        super.dictTableView = tableView
        
        
        DAO = PriorityDaoDbImpl.current
        
        // используем sortDescriptors в DAO
        //DAO.items.sort(by: { $0.index < $1.index })
        
        initNavBar()
    }
    
    // MARK: @IBActions
    
    
    // закрытие контроллера без сохранения
    @IBAction func tapCancel(_ sender: UIBarButtonItem) {
        
        cancel()
        
    }
    
    @IBAction func tapSave(_ sender: UIBarButtonItem) {
        
        save()
        
    }
    
    @IBAction func tapCheckPriority(_ sender: UIButton) {
        
        // определяем индекс строки по нажатой кнопке в ячейке
        let viewPosition = sender.convert(CGPoint.zero, to: dictTableView) // координата относительно tableView
        let indexPath = dictTableView.indexPathForRow(at: viewPosition)!
        
        checkItem(indexPath)
        
    }
    
    @IBAction func tapSelectDeselect(_ sender: UIButton) {
        super.selectDeselectItems()
    }
    
    // MARK: tableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellPriority", for: indexPath) as? PriorityListCell else { fatalError("fatal erroe with cell") }
        
        cell.selectionStyle = .none // чтобы не выделялась строка
        
        let priority = DAO.items[indexPath.row]
        
        cell.labelPriorityName.text = priority.name
        
        cell.selectionStyle = .none // чтобы не выделялась строка
        
        cell.labelPriorityName.textColor = .darkGray
        labelHeaderTitle.textColor = .lightGray
        
        if showMode == .edit {
            
            buttonSelectDeselectAll.isHidden = false
            
            // для переноса текста на новую строку
            labelHeaderTitle.lineBreakMode = .byWordWrapping
            labelHeaderTitle.numberOfLines = 0
            
            labelHeaderTitle.text = "Вы можете фильтровать задачи с помощью выбора приоритетов"
            
            if priority.checked {
                cell.buttonCheckPriority.setImage(UIImage(named: "check_green"), for: .normal)
                currentCheckedIndexPath = indexPath
            } else {
                cell.buttonCheckPriority.setImage(UIImage(named: "check_gray"), for: .normal)
            }
            
            tableView.allowsMultipleSelection = true // при фильтрации задач - выбирать любое количество категорий
            
            // если последняя запись (таблица полностью загрузилась)
            if indexPath.row == DAO.items.count-1 {
                updateSelectDeselectButton()
            }
            
        } else if showMode == .select {
            
            tableView.allowsMultipleSelection = false
            
            buttonSelectDeselectAll.isHidden = true
            
            labelHeaderTitle.text = "Выберите один приоритет для задачи"
            
            
            if selectedItem != nil && selectedItem == priority {
                currentCheckedIndexPath = indexPath
                cell.buttonCheckPriority.setImage(UIImage(named: "check_green"), for: .normal)
            } else {
                cell.buttonCheckPriority.setImage(UIImage(named: "check_gray"), for: .normal)
            }
            
        }
        
        return cell
        
    }
    
    // нажатие на строку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if showMode == .edit {
            editPriority(indexPath: indexPath) // в режиме edit - переходим к редактированию
            return
        } else if showMode == .select {
            checkItem(indexPath) // в режиме select - выбираем элемент (для задачи)
            return
        }
        
    }
    
    // редактирование категории
    func editPriority(indexPath: IndexPath) {
        
        // определяем какой именно объект редактируем (чтобы потом сохранять именно его)
        let currentItem = self.DAO.items[indexPath.row]
        
        // запоминаем старое значение (чтобы потом понимать, было ли изменение и не выполнять лишних действий)
        let oldValue = currentItem.name
        
        // показываем диалоговое окно и реализуем замыкание, которое будет выполняться при нажатии на кнопку ОК
        showDialog(title: "Редактирование", message: "Введите название", initValue: currentItem.name!, actionClousure: { name in
            
            if !self.isEmptyTrim(name){ //значение name из текстового поля передается в замыкание
                currentItem.name = name
            } else {
                currentItem.name = "Новый приоритет"
            }
            
            if currentItem.name != oldValue{
                //  обновляем в БД и в таблице
                self.updateItem(currentItem)
                
                self.changed = true // произошли изменения
            } else {
                self.changed = false
            }
            
        })
        
        
    }
    
    // редактирование приоритетов
    override func add() {
        
        showDialog(title: "Новый приоритет", message: "Введите название") { (name) in
            
            let newPriority = Priority(context: self.DAO.context)
            newPriority.name = name // имя получаем как параметр замыкания
            self.addItem(newPriority)
            
        }
        
    }
    
    // MARK: override
    override func getAll() -> [Priority] {
        return DAO.getAll(sortType: PrioritySortType.index)
    }
    
    override func search(_ text: String) -> [Priority] {
        return DAO.search(text: text, sortType: PrioritySortType.index)
    }
    
}
