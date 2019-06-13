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

class CategoryViewController: UITableViewController {

    var categories: Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    // MARK: - IBAction
    
    @IBAction func addButtonDidClicked(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: "添加新的类别", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "添加", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            
//            self.categories.append(newCategory)
            
            self.saveCategories(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "添加一个新的类别"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "没有任何类别"
        
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
    
}
