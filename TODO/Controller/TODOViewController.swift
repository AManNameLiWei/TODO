//
//  TODOListViewController.swift
//  TODO
//
//  Created by 厉威 on 2019/6/10.
//  Copyright © 2019 厉威. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TODOViewController: UITableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour {
            
            //设置控制器名称为类别名称
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else{
                fatalError("导航栏不存在")
            }
            
            if let navBarColor = UIColor(hexString: colourHex){
                //设置导航栏背景颜色
               navBar.barTintColor = navBarColor
                //设置导航栏按钮文字颜色  对比色
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                //设置导航栏标题颜色
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                //设置搜索栏背景颜色
                searchBar.barTintColor = navBarColor
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let originColor = UIColor(hexString: "#FFCB73") else {
            fatalError()
        }
        //控制器即将消失 颜色还原
        navigationController?.navigationBar.barTintColor = originColor
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }
    
    // MARK: - IBAction
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        //创建弹窗控制器
        let alert = UIAlertController(title: "添加一个新的TODO项目", message: "", preferredStyle: .alert)
        
        //创建动作
        let action = UIAlertAction(title: "添加项目", style:.default) { (action) in
            //用户单击添加项目按钮以后执行的代码
            
            if let currentCategory = self.selectedCategory{
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.date = Date() //Date()返回当前的时间
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("保存Item错误")
                }
            }
            
            //刷新界面
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addTextField { (alerttextField) in
            alerttextField.placeholder = "创建一个新项目"
            //让textField指向alertTextField，因为出了闭包，alertTextField不存在
            textField = alerttextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    // MARK: - 自定义方法
    
    //在参数内部赋默认值，外部调用方法时就不用给参数了
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "date", ascending: true)
        
        tableView.reloadData()
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done == true ? .checkmark : .none
            
            //设置背景颜色为事务类别颜色
            //darken用来设置阴暗程度  0——1
            if let colour = UIColor(hexString: self.selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = colour
                
                //根据背景颜色自动设定文本颜色  returnFlat用于确定是否平涂
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
        }else{
            cell.textLabel?.text = "没有事项"
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        //解包后数据存在则改变状态写入数据库
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch{
                print("保存完成状态失败")
            }
            
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.endUpdates()
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
        // MARK: - 系统自带滑动功能
        /*
         override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         let deleteAction = UIContextualAction(style: .destructive, title: "删除") { (UIContextualAction, UIView, (Bool) -> Void) in
         //修改数据源
         self.context.delete(self.itemsArray[indexPath.row])
         self.itemsArray.remove(at: indexPath.row)
         self.saveItems()
         
         tableView.deleteRows(at: [indexPath], with: .fade)
         tableView.reloadData()
         }
         
         let sharedAction = UIContextualAction(style: .normal, title: "分享") { (UIContextualAction, UIView, (Bool) -> Void) in
         let text = "这是分享功能"
         
         let ac = UIActivityViewController(activityItems: [text], applicationActivities: nil)
         
         self.present(ac, animated: true, completion: nil)
         }
         
         sharedAction.backgroundColor = UIColor.green
         
         let actinos = UISwipeActionsConfiguration.init(actions: [deleteAction,sharedAction])
         
         return actinos
         
         }
         */
    }
}


extension TODOViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //根据文本框内容搜索，返回一个排序的搜索集
        todoItems = todoItems?.filter("title CONTAINS[c] %@", searchBar.text!).sorted(byKeyPath: "date", ascending: false)
        
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

extension TODOViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return nil
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "删除") { (action, indexPath) in
            if let itemForDelection = self.todoItems?[indexPath.row]{
                do{
                    try self.realm.write {
                        self.realm.delete(itemForDelection)
                    }
                }catch{
                    print("删除事项失败：\(error)")
                }
            }
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}
