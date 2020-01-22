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
            try? self.realm.write ({
                realm.delete((categoryNames?[indexPath.row])!)
            })
            myTableView.reloadData()
        }
    }
    
    @IBAction func homePlusButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "New Category", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.textFields![0].placeholder = "Enter a name..."
        
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
        let alert = UIAlertController(title: "Move", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
