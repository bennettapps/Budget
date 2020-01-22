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
    
    var categoryNames: Results<Category>?
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryNames = realm.objects(Category.self)
        myTableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categoryNames?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = categoryNames?[indexPath.row].title
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if(editingStyle == UITableViewCell.EditingStyle.delete)
        {
            deleteRow(row: indexPath.row)
        }
    }
    
    func deleteRow(row: Int) {
        try? self.realm.write ({
            realm.delete((categoryNames?[row])!)
        })
        myTableView.reloadData()
    }
    
    @IBAction func homePlusButtonClicked(_ sender: Any) {
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
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        self.myTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            self.deleteRow(row: indexPath.row)
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
                    let newCategory = self.categoryNames![indexPath.row]
                    do {
                        try self.realm.write {
                            newCategory.title = alert.textFields![0].text!
                        }
                    } catch {
                        print("Error saving category \(error)")
                    }
                    
                    self.myTableView.reloadData()
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
