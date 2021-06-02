//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        print(dataFilePath)
        

        loadItems()
    }
    
    //MARK:- add new item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var xTextField = UITextField()
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            print("Success!")
            let newItem = Item()
            if xTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                newItem.title = xTextField.text!
                self.itemArray.append(newItem)
                //                self.defaults.set(self.itemArray, forKey: "TodoListArray")
                self.saveItems()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            xTextField = alertTextField
            //            xTextField.text = alertTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        alert.addAction(action)
        present(alert, animated: true, completion:  nil)
    }
    
    func saveItems(){
        do{
            let data = try PropertyListEncoder().encode(itemArray)
            try data.write(to: dataFilePath!)
        }catch{
            print("Error encoding: \(error)")
        }
        tableView.reloadData()
    }
    func loadItems(){
        if let data = try? Data(contentsOf: dataFilePath!){
            do{
                itemArray = try PropertyListDecoder().decode([Item].self, from: data)
            } catch{
                print("Error: \(error)")
            }
        }
    }
}

//MARK:- TableView
extension TodoListViewController{
    
    
    override func tableView(_ tableview:UITableView, numberOfRowsInSection section:Int)->Int{
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        //        tableView.reloadData()
        
        
    }
    
}
