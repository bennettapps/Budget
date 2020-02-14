//
//  ViewController.swift
//  Budget
//
//  Created by Jesse on 12/28/19.
//  Copyright © 2019 Bennett Apps. All rights reserved.
//
import UIKit
import RealmSwift

class TransactionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let realm = try! Realm()
    var transactionList: Results<Transactions>?
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() { // load up and read data
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        transactionList = realm.objects(Transactions.self)
        myTableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int // set correct number of rows
    {
        return transactionList?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell // set all the titles
    {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        cell.dollarText.text = String(format: "$%.2f", transactionList![indexPath.row].amount)
        cell.categoryText.text = "Category: " + realm.objects(Category.self)[transactionList![indexPath.row].category].title
        cell.accountText.text = "Account: " + realm.objects(Accounts.self)[transactionList![indexPath.row].account].title
        cell.textLabel?.text = transactionList?[indexPath.row].title
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
        
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: {(action) in
            let alert = UIAlertController(title: "Edit Transaction", message: nil, preferredStyle: UIAlertController.Style.alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields![0].placeholder = "Enter a name..."
            alert.textFields![0].text = self.transactionList![indexPath.row].title
            alert.textFields![0].autocorrectionType = .yes
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields![1].placeholder = "Enter amount..."
            alert.textFields![1].keyboardType = .decimalPad
            alert.textFields![1].text = String(self.transactionList![indexPath.row].amount)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: {(action) in
                if(alert.textFields![0].hasText) {
                    let newTransaction = Transactions()
                    newTransaction.title = alert.textFields![0].text!
                    newTransaction.amount = (alert.textFields![1].text! as NSString).floatValue
                    self.update(transaction: newTransaction, i: indexPath.row)
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func plusButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "TransferPopup")
        self.present(controller, animated: true, completion: nil)
        (controller as! CategoryPickerView).presenter = self
    }
        
    func onDismissPopup() {
        print("completed")
    }
    
    func delete(row: Int) { // delete row, and move the balance up to "to be budgeted"
        let alert = UIAlertController(title: "Delete?", message: "Transaction will be Deleted and the Balance will be gone forever", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: {(action) in
            try? self.realm.write ({
                self.realm.delete((self.transactionList?[row])!)
                self.transactionList = self.realm.objects(Transactions.self)
            })
            self.myTableView.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func save(transaction: Transactions) { // save row
        do {
            try realm.write {
                let newTransaction = Transactions()
                newTransaction.title = transaction.title
                newTransaction.amount = transaction.amount
                newTransaction.category = transaction.category
                newTransaction.account = transaction.account
                realm.add(newTransaction)
            }
            
            try realm.write {
                let categories = realm.objects(Category.self)
                categories[transaction.category].amount += transaction.amount
            }
            
            try realm.write {
                let accounts = realm.objects(Accounts.self)
                accounts[transaction.account].balance += transaction.amount
            }
        } catch {
            print("Error saving transaction \(error)")
        }
        
        self.myTableView.reloadData()
    }
    
    func update(transaction: Transactions, i: Int) { // update row
        do {
            try realm.write {
                let categories = realm.objects(Category.self)
                categories[transactionList![i].category].amount -= transactionList![i].amount
                categories[transaction.category].amount += transaction.amount
            }
            
            try realm.write {
                let accounts = realm.objects(Accounts.self)
                accounts[transactionList![i].account].balance -= transactionList![i].amount
                accounts[transaction.account].balance += transaction.amount
            }
            
            try realm.write {
                transactionList![i].title = transaction.title
                transactionList![i].amount = transaction.amount
            }
        } catch {
            print("Error updating transaction \(error)")
        }
        
        self.myTableView.reloadData()
    }
}
