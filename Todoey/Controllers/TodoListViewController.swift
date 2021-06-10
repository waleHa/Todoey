//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController{
    
    var itemArray = [Item]()
    
    var selectedCategory : Category?{
        didSet{
            loadItems();
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
//        loadItems()
    }
    
    //MARK:- add new item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var xTextField = UITextField()
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            print("Success!")
            
            
            let newItem = Item(context: self.context)
            if xTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                newItem.title = xTextField.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory!
                self.itemArray.append(newItem)
                self.saveItems()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            xTextField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion:  nil)
    }
    
    //MARK:- Data Manipulation - Save/load data
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error saving context: \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request:NSFetchRequest<Item> = Item.fetchRequest()){
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if request.predicate == nil{
        request.predicate = predicate
        }
        do{ // context.fetch() will return NSFetchRequestResult => NSFetchRequest<Item>
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data: \(error)")
        }
        tableView.reloadData()
    }
}

//MARK:- UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()

        if searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
        }
        else{
            let predicate1 = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            let predicate2 = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            request.predicate =   NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2] )//add the query to the request
                
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
        loadItems(with: request)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()//dismiss
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
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete{
        
        context.delete(itemArray[indexPath.row])
        
        self.itemArray.remove(at: indexPath.row)

        self.saveItems()
        }
    }
}
