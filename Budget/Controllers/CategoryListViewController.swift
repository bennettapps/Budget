//
//  ViewController.swift
//  Budget
//
//  Created by Jesse on 12/28/19.
//  Copyright © 2019 Bennett Apps. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    var categoryNames: Results<Category>?
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var toBeBudgeted: UILabel!
    
    override func viewDidLoad() { // load up and read data
        super.viewDidLoad()
        categoryNames = realm.objects(Category.self)
        myTableView.reloadData()
        toBeBudgeted.text = "$" + String(defaults.float(forKey: "ToBeBudgeted"))
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int // set correct number of rows
    {
        return categoryNames?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell // set all the titles
    {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryTableViewCell
        cell.valueText.text = "$" + String(categoryNames![indexPath.row].amount)
        cell.textLabel?.text = categoryNames?[indexPath.row].title
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) // delete by swiping
    {
        if(editingStyle == UITableViewCell.EditingStyle.delete)
        {
            delete(row: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // selected row
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            self.delete(row: indexPath.row)
        }))
        alert.addAction(UIAlertAction(title: "Transfer", style: .default, handler: {(action) in
            
        }))
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: {(action) in
            let alert = UIAlertController(title: "Edit Category", message: nil, preferredStyle: UIAlertController.Style.alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields![0].placeholder = "Enter a name..."
            alert.textFields![0].text = self.categoryNames![indexPath.row].title
            alert.textFields![0].autocorrectionType = .yes
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: {(action) in
                if(alert.textFields![0].hasText) {
                    let newCategory = Category()
                    newCategory.title = alert.textFields![0].text!
                    self.update(category: newCategory, i: indexPath.row)
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func homePlusButtonClicked(_ sender: Any) { // clicked the plus button
        let alert = UIAlertController(title: "New Category", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.textFields![0].placeholder = "Enter a name..."
        alert.textFields![0].autocorrectionType = .yes
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Create", style: UIAlertAction.Style.default, handler: {(action) in
            if(alert.textFields![0].hasText) {
                let newCategory = Category()
                newCategory.title = alert.textFields![0].text!
                self.save(category: newCategory)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func delete(row: Int) { // delete row
        try? self.realm.write ({
            realm.delete((categoryNames?[row])!)
            categoryNames = realm.objects(Category.self)
        })
        myTableView.reloadData()
    }
    
    func save(category: Category) { // save row
        do {
            try realm.write {
                let newCategory = Category()
                newCategory.title = category.title
                realm.add(newCategory)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        self.myTableView.reloadData()
    }
    
    func update(category: Category, i: Int) { // update row
        do {
            try realm.write {
                categoryNames![i].title = category.title
            }
        } catch {
            print("Error updating category \(error)")
        }
        
        self.myTableView.reloadData()
    }
}
