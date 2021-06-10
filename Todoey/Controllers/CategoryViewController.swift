//
//  CategoryViewController.swift
//  Todoey
//
//  Created by admin on 2021-06-09.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
                loadCategory()
    }

    //MARK:- add buttton
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //4
        var xTextField = UITextField()
        //1
        let alert = UIAlertController(title: "Add New Todo Category", message: "", preferredStyle: .alert)
        //5
        let action = UIAlertAction(title: "Add a Category", style: .default) { (action) in
            print("Success!")
            let newCategory = Category(context: self.context)
            if xTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                newCategory.name = xTextField.text!
                self.categoryArray.append(newCategory)
                self.saveCategory()
            }
        }
        //2
        alert.addAction(action)
        //3
        alert.addTextField { (field) in
            xTextField = field
            field.placeholder = "Create a new Category"
        }
        //6
        present(alert, animated: true, completion:  nil)
    }
    
    
    
    //MARK:- Data Manipulation - Save/load data
        func saveCategory(){
            do{
                try context.save()
            }catch{
                print("Error saving context: \(error.localizedDescription)")
            }
            tableView.reloadData()
        }
        
        func loadCategory(with request:NSFetchRequest<Category> = Category.fetchRequest()){
            do{ // context.fetch() will return NSFetchRequestResult => NSFetchRequest<Category>
                categoryArray = try context.fetch(request)
            }catch{
                print("Error fetching data: \(error)")
            }
            tableView.reloadData()
        }
}

    //MARK:- TableView DataSource
//MARK:- TableView
extension CategoryViewController{
    override func tableView(_ tableview:UITableView, numberOfRowsInSection section:Int)->Int{
        return categoryArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
                
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete{
        
        context.delete(categoryArray[indexPath.row])
        
        self.categoryArray.remove(at: indexPath.row)

        self.saveCategory()
        }
    }
    //MARK:- TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems"{
            let destinationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categoryArray[indexPath.row]
            }
        }
    }
}

    

    

