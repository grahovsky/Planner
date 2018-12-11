//
//  CategoryListController.swift
//  Planner
//
//  Created by Konstantin on 24/11/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit

class CategoryListController: DictonaryController<CategoryDaoDbImpl>{
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dictTableView = tableView
        DAO = CategoryDaoDbImpl.current
        DAO.getAll(sortType:CategorySortType.name)
        
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
    
    
    @IBAction func tapCheckCategory(_ sender: UIButton) {
        
        // определяем индекс строки по нажатой кнопке в ячейке
        let viewPosition = sender.convert(CGPoint.zero, to: dictTableView) // координата относительно tableView
        let indexPath = dictTableView.indexPathForRow(at: viewPosition)!
        
        checkItem(indexPath)
        
    }
    
    // MARK: tableView
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory", for: indexPath) as? CategoryListCell else { fatalError("fatal erroe with cell") }
        
        cell.selectionStyle = .none // чтобы не выделялась строка
        
        let category = DAO.items[indexPath.row]
        
        if selectedItem != nil && selectedItem == category {
            currentCheckedIndexPath = indexPath
            cell.buttonCheckCategory.setImage(UIImage(named: "check_green"), for: .normal)
        } else {
            cell.buttonCheckCategory.setImage(UIImage(named: "check_gray"), for: .normal)
        }
        
        cell.labelCategoryName.text = category.name
        
        return cell
        
    }
    
    // нажатие на строку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if showMode == .edit {
            editCategory(indexPath: indexPath) // в режиме edit - переходим к редактированию
            return
        } else if showMode == .select {
            checkItem(indexPath) // в режиме select - выбираем элемент (для задачи)
            return
        }
        
    }
    
    // редактирование категории
    func editCategory(indexPath: IndexPath) {
        
        // определяем какой именно объект редактируем (чтобы потом сохранять именно его)
        let currentItem = self.DAO.items[indexPath.row]
        
        // запоминаем старое значение (чтобы потом понимать, было ли изменение и не выполнять лишних действий)
        let oldValue = currentItem.name
        
        // показываем диалоговое окно и реализуем замыкание, которое будет выполняться при нажатии на кнопку ОК
        showDialog(title: "Редактирование", message: "Введите название", initValue: currentItem.name!, actionClousure: { name in
            
            if !self.isEmptyTrim(name){ //значение name из текстового поля передается в замыкание
                currentItem.name = name
            } else {
                currentItem.name = "Новая категория"
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
    
    // редактирование категории
    override func add() {
        
        showDialog(title: "Новая категория", message: "Введите название") { (name) in
            
            let newCategory = Category(context: self.DAO.context)
            newCategory.name = name // имя получаем как параметр замыкания
            self.addItem(newCategory)
            
        }
        
    }
    
    
    // MARK: override
    override func getAll() -> [Category] {
        return DAO.getAll(sortType: CategorySortType.name)
    }
    
    override func search(_ text: String) -> [Category] {
        return DAO.search(text: text, sortType: CategorySortType.name)
    }
    
}

