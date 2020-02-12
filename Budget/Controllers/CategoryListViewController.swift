//
//  ViewController.swift
//  Budget
//
//  Created by Jesse on 12/28/19.
//  Copyright © 2019 Bennett Apps. All rights reserved.
//
import UIKit
import RealmSwift

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}

class CategoryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    var categoryNames: Results<Category>?
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var toBeBudgeted: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() { // load up and read data
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        categoryNames = realm.objects(Category.self)
        myTableView.reloadData()
        toBeBudgeted.text = String(format: "$%.2f", defaults.float(forKey: "ToBeBudgeted"))
        stackView.addBackground(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int // set correct number of rows
    {
        return categoryNames?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell // set all the titles
    {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryTableViewCell
        cell.valueText.text = String(format: "$%.2f", categoryNames![indexPath.row].amount)
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
            //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //            let myModalViewController = storyboard.instantiateViewController(withIdentifier: "TransferPopup")
            //            myModalViewController.modalPresentationStyle = UIModalPresentationStyle.automatic
            //            myModalViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            //            self.present(myModalViewController, animated: true, completion: nil)
            
            
            let alert = UIAlertController(title: "Transfer Money", message: "This will go from To Be Budgeted for now", preferredStyle: UIAlertController.Style.alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields![0].placeholder = "How much to transfer..."
            alert.textFields![0].keyboardType = .decimalPad
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Transfer", style: UIAlertAction.Style.default, handler: {(action) in
                if(alert.textFields![0].hasText) {
                    let newCategory = Category()
                    newCategory.title = self.categoryNames![indexPath.row].title
                    newCategory.amount = self.categoryNames![indexPath.row].amount + (alert.textFields![0].text! as NSString).floatValue
                    self.defaults.set(self.defaults.float(forKey: "ToBeBudgeted") - newCategory.amount, forKey: "ToBeBudgeted")
                    self.toBeBudgeted.text = String(format: "$%.2f", self.defaults.float(forKey: "ToBeBudgeted"))
                    self.update(category: newCategory, i: indexPath.row)
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
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
                    newCategory.amount = self.categoryNames![indexPath.row].amount
                    self.update(category: newCategory, i: indexPath.row)
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
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
    
    func delete(row: Int) { // delete row, and move the balance up to "to be budgeted"
        let alert = UIAlertController(title: "Delete?", message: "Category will be Deleted and the Balance will be Transferred back to 'To Be Budgeted'", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: {(action) in
            try? self.realm.write ({
                let deletingBalance = self.categoryNames?[row].amount
                self.defaults.set(self.defaults.float(forKey: "ToBeBudgeted") + deletingBalance!, forKey: "ToBeBudgeted")
                self.toBeBudgeted.text = String(format: "$%.2f", self.defaults.float(forKey: "ToBeBudgeted"))
                self.realm.delete((self.categoryNames?[row])!)
                self.categoryNames = self.realm.objects(Category.self)
            })
            self.myTableView.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
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
                categoryNames![i].amount = category.amount
            }
        } catch {
            print("Error updating category \(error)")
        }
        
        self.myTableView.reloadData()
    }
}
