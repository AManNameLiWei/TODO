//
//  CategoryViewController.swift
//  TODO
//
//  Created by 厉威 on 2019/6/11.
//  Copyright © 2019 厉威. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: UITableViewController{

    var categories: Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        loadCategories()
    }

    // MARK: - IBAction
    
    @IBAction func addButtonDidClicked(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: "添加新的类别", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "添加", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            
            //保存颜色名称
            newCategory.colour = UIColor.randomFlat.hexValue()
            
            self.saveCategories(category: newCategory)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "添加一个新的类别"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - tableView数据维护
    func saveCategories(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("存储错误：\(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories(){
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    // MARK: - Delegate && DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "没有任何类别"
        
        //设置背景颜色为随机颜色
        guard let categoryColor = UIColor(hexString: self.categories?[indexPath.row].colour ?? "1D9BF6") else{
            fatalError()
        }
        
        //设置文字颜色  与背景颜色为对比色
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        
        //设置背景颜色
        cell.backgroundColor = categoryColor
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    
    // MARK: - 重写方法
    //进入下一个控制器前进行赋值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TODOViewController
        if segue.identifier == "goToItems" {
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension CategoryViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return nil
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "删除") { (action, indexPath) in
            if let categoryForDelection = self.categories?[indexPath.row]{
                do {
                    try self.realm.write {
                        self.realm.delete(categoryForDelection)
                    }
                }catch{
                    print("删除类别错误\(error)")
                }
                
            }
            
        }
        
        //自定义按钮外观
        deleteAction.image = UIImage(named: "Trash-Icon");
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        
        var options = SwipeTableOptions()
        
        options.expansionStyle = .destructive
        
        return options
    }
}
