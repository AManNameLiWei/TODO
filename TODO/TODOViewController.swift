//
//  TODOListViewController.swift
//  TODO
//
//  Created by 厉威 on 2019/6/10.
//  Copyright © 2019 厉威. All rights reserved.
//

import UIKit

class TODOViewController: UITableViewController {
    
    var itemsArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    
//    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath!)
        //从本地读取数据
        loadItems()
        
    }
    
    // MARK: - IBAction
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        //创建弹窗控制器
        let alert = UIAlertController(title: "添加一个新的TODO项目", message: "", preferredStyle: .alert)
        
        //创建动作
        let action = UIAlertAction(title: "添加项目", style:.default) { (action) in
            //用户单击添加项目按钮以后执行的代码
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemsArray.append(newItem)
            
            //写入磁盘
            self.saveItems()
            
            //会将数据保存在Library/Preferences中
//            self.defaults.set(self.itemsArray, forKey: "TODOListArray")
            
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
        //实例化编码对象
        let encoder = PropertyListEncoder()
        
        //对数组进行编码 -> Data
        do {
            let data = try encoder.encode(self.itemsArray)
            
            try data.write(to: self.dataFilePath!)
        }catch{
            print("编码错误：\(error)")
        }
    }
    
    func loadItems(){
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            //实例化解码对象
            let decoder = PropertyListDecoder()
            
            //对data进行解码
            do{
                itemsArray = try decoder.decode([Item].self, from: data)
            }catch{
                print("解码items错误")
            }
        }
        
        
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
        
        //点击之后重新编码写入磁盘
        saveItems()
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

