//
//  TODOListViewController.swift
//  TODO
//
//  Created by 厉威 on 2019/6/10.
//  Copyright © 2019 厉威. All rights reserved.
//

import UIKit
import CoreData

class TODOViewController: UITableViewController {
    
    var itemsArray = [Item]()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    

    //获取临时区域
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - IBAction
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        //创建弹窗控制器
        let alert = UIAlertController(title: "添加一个新的TODO项目", message: "", preferredStyle: .alert)
        
        //创建动作
        let action = UIAlertAction(title: "添加项目", style:.default) { (action) in
            //用户单击添加项目按钮以后执行的代码
            
            //初始化item类
            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done = false //默认值为false
            
            //为新建的item对象parentCategory属性赋值
            newItem.parentCategory = self.selectedCategory
            
            self.itemsArray.append(newItem)
            
            //写入磁盘
            self.saveItems()
            
            //刷新界面
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alerttextField) in
            alerttextField.placeholder = "创建一个新项目"
            //让textField指向alertTextField，因为出了闭包，alertTextField不存在
            textField = alerttextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    // MARK: - 自定义方法
    func saveItems(){
        
        do {
            try context.save()
            
        }catch{
            print("保存context错误：\(error)")
        }
    }
    
    //在参数内部赋默认值，外部调用方法时就不用给参数了
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil ){
        
        //创建NSFetchRequest变量  自定义搜索请求
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", self.selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,addtionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        
        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("从context获取数据错误:\(error)")
        }
        
        tableView.reloadData()
    }
 
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        
        cell.textLabel?.text = itemsArray[indexPath.row].title
        
        if itemsArray[indexPath.row].done == false {
            cell.accessoryType = .none
        }else{
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        itemsArray[indexPath.row].done = !itemsArray[indexPath.row].done
        
        
        //修改数据
        
        //单击某个事项时候会加上已完成字样 在save之前不会影响内部已存数据
//        let title = itemsArray[indexPath.row].title
//        itemsArray[indexPath.row].setValue(title! + "-(已完成)", forKey: "title")
        
        //删除数据
        
//        context.delete(itemsArray[indexPath.row])
//        itemsArray.remove(at: indexPath.row)
        
        
        
        //点击之后重新编码写入磁盘
        saveItems()
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension TODOViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        //搜索条件
        request.predicate = NSPredicate(format: "title CONTAINS[c] %@", searchBar.text!)
        
        //搜索结果排序
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //执行搜索
        loadItems(with: request, predicate: request.predicate)
        
//        print(searchBar.text!)
    }
    
    //搜索结束，关闭搜索
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //在后台线程运行
            loadItems()
            
            //在主线程中取消第一响应者，键盘消失
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()

            }
        }
    }
}

