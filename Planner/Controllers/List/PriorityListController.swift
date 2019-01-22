//
//  PriorityListController.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class PriorityListController: DictonaryController<PriorityDaoDbImpl>, ActionResultDelegate {
    
    func cancel(source: UIViewController, data: Any?) {
        cancel()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelHeaderTitle: UILabel!    
    @IBOutlet weak var buttonSelectDeselectAll: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        super.buttonSelectDeselectDict = buttonSelectDeselectAll
        super.tableViewDict = tableView
        super.labelHeaderTitleDict = labelHeaderTitle
        
        
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
        let viewPosition = sender.convert(CGPoint.zero, to: tableViewDict) // координата относительно tableView
        let indexPath = tableViewDict.indexPathForRow(at: viewPosition)!
        
        checkItem(indexPath)
        
    }
    
    @IBAction func tapSelectDeselect(_ sender: UIButton) {
        super.selectDeselectItems()
    }
    
    // MARK: tableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellPriority", for: indexPath) as? PriorityListCell else { fatalError("fatal erroe with cell") }
        
        let priority = DAO.items[indexPath.row]
        
        cell.labelPriorityName.text = priority.name
        
        cell.selectionStyle = .none // чтобы не выделялась строка
        
        cell.labelPriorityName.textColor = .darkGray
        
        if let color = priority.color {
            cell.labelPriorityColor.backgroundColor = color as? UIColor
        }
        
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
    
    // редактирование категории
    func editPriority(indexPath: IndexPath) {
        
        // определяем какой именно объект редактируем (чтобы потом сохранять именно его)
        let currentItem = self.DAO.items[indexPath.row]
        
        // запоминаем старое значение (чтобы потом понимать, было ли изменение и не выполнять лишних действий)
        let oldValue = currentItem.name
        
        // показываем диалоговое окно и реализуем замыкание, которое будет выполняться при нажатии на кнопку ОК
        showDialog(title: "Редактирование", message: "Введите название", initValue: currentItem.name!, actionClosure: { name in
            
            if !self.isEmptyTrim(name){ //значение name из текстового поля передается в замыкание
                currentItem.name = name
            } else {
                currentItem.name = "Новый приоритет"
            }
            
            if currentItem.name != oldValue{
                //  обновляем в БД и в таблице
                self.updateItem(currentItem, indexPath: indexPath)
                
                self.changed = true // произошли изменения
            } else {
                self.changed = false
            }
            
        })
        
        
    }
    
    // MARK: override
    override func getAll() -> [Priority] {
        return DAO.getAll(sortType: PrioritySortType.index)
    }
    
    override func search(_ text: String) -> [Priority] {
        return DAO.search(text: text, sortType: PrioritySortType.index)
    }
    
    // MARK: prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditPriority" {
            
            guard let controller = segue.destination as? EditPriorityController else {
                fatalError("error")
            }
            
            controller.priority = DAO.items[tableView.indexPathForSelectedRow!.row] // какой элемент в данный момент редактируем
            controller.navigationTitle = "Редактирование"
            controller.delegate = self
            
            return
            
        }
        
        
        if segue.identifier == "AddPriority" {
            
            guard let controller = segue.destination as? EditPriorityController else {
                fatalError("error")
            }
            
            controller.navigationTitle = "Новый приоритет"
            
            controller.delegate = self
            
            return
            
        }
    }
    
    // MARK: ActionResultDelegate
    
    func done(source: UIViewController, data: Any?) {
        
        if source is EditPriorityController{
            
            let priority = data as! Priority
            
            // обновление
            if let selectedIndexPath = tableView.indexPathForSelectedRow { // определяем выбранную до этого строку (если была нажата какая-либо строка)
                
                updateItem(priority, indexPath: selectedIndexPath)
                
            } else { // новая задача
                
                addItem(priority)
                
            }
            
            changed = true // произошли изменения
            
        }
    }
    
    
    // MARK: override
    
    override func addItemAction(){
        performSegue(withIdentifier: "AddPriority", sender: self)
    }
    
    override func editItemAction(indexPath:IndexPath){
        performSegue(withIdentifier: "EditPriority", sender: self)
    }
    
}
