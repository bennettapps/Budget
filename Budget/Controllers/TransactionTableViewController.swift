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
    let defaults = UserDefaults.standard
    
    var transactionList: Results<Transactions>?
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() { // load up and read data
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(realm.objects(Accounts.self).count < 1) {
            let alert = UIAlertController(title: "Need Accounts", message: "You must create at least one account before making transactions", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Accounts", style: UIAlertAction.Style.default, handler: {(action) in
                self.tabBarController?.selectedIndex = 1
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            transactionList = realm.objects(Transactions.self)
            myTableView.reloadData()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int // set correct number of rows
    {
        return transactionList?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell // set all the titles
    {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        cell.dollarText.text = String(format: "$%.2f", transactionList![indexPath.row].amount)
        if(transactionList![indexPath.row].category != 0) {
            let categories = realm.objects(Category.self)
            
            if(categories.count >= transactionList![indexPath.row].category) {
                cell.categoryText.text = categories[transactionList![indexPath.row].category - 1].title
            } else {
                cell.categoryText.text = "MISSING"
            }
        } else {
            cell.categoryText.text = "To Be Budgeted"
        }
        
        let accounts = realm.objects(Accounts.self)
        if(accounts.count >= transactionList![indexPath.row].account + 1) {
            cell.accountText.text = accounts[transactionList![indexPath.row].account].title
            cell.textLabel?.text = transactionList?[indexPath.row].title
        } else {
            cell.accountText.text = "MISSING"
        }
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "TransferPopup")
            self.present(controller, animated: true, completion: nil)
            let pickerView = (controller as! CategoryPickerView)
            pickerView.presenter = self
            pickerView.edit = true
            pickerView.i = indexPath.row
            pickerView.titleText.text = self.transactionList![indexPath.row].title
            pickerView.amountText.text = String(abs(self.transactionList![indexPath.row].amount))
            if(self.transactionList![indexPath.row].amount > 0) {
                pickerView.positiveSwitch.isOn = true
            }
            pickerView.setStartingSelected(category: self.transactionList![indexPath.row].category, account: self.transactionList![indexPath.row].account)
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
    
    func delete(row: Int) { // delete row, and move the balance up to "to be budgeted"
        let alert = UIAlertController(title: "Delete?", message: "Transaction will be Deleted and the Balance will be returned", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: {(action) in
            let categories = self.realm.objects(Category.self)
            let accounts = self.realm.objects(Accounts.self)
            let balance = self.transactionList?[row].amount

            try? self.realm.write ({
                let category = self.transactionList?[row].category
                if(category != 0) {
                    categories[category! - 1].amount -= balance!
                } else {
                    self.defaults.set(self.defaults.float(forKey: "ToBeBudgeted") - balance!, forKey: "ToBeBudgeted")
                }
                accounts[(self.transactionList?[row].account)!].balance -= balance!
            })
            
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
            print(transaction.category)
            try realm.write {
                let newTransaction = Transactions()
                newTransaction.title = transaction.title
                newTransaction.amount = transaction.amount
                newTransaction.category = transaction.category
                newTransaction.account = transaction.account
                realm.add(newTransaction)
            }
            
            if(transaction.category != 0) {
                try realm.write {
                    let categories = realm.objects(Category.self)
                    categories[transaction.category - 1].amount += transaction.amount
                }
            } else {
                defaults.set(defaults.float(forKey: "ToBeBudgeted") + transaction.amount, forKey: "ToBeBudgeted")
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
            print(transaction.category)
            if(transaction.category != 0) {
                try realm.write {
                    let categories = realm.objects(Category.self)
                    categories[transactionList![i].category - 1].amount -= transactionList![i].amount
                    categories[transaction.category - 1].amount += transaction.amount
                }
            } else {
                defaults.set(defaults.float(forKey: "ToBeBudgeted") + transaction.amount, forKey: "ToBeBudgeted")
            }
            
            try realm.write {
                let accounts = realm.objects(Accounts.self)
                accounts[transactionList![i].account].balance -= transactionList![i].amount
                accounts[transaction.account].balance += transaction.amount
            }
            
            try realm.write {
                transactionList![i].title = transaction.title
                transactionList![i].amount = transaction.amount
                transactionList![i].category = transaction.category
                transactionList![i].account = transaction.account
            }
        } catch {
            print("Error updating transaction \(error)")
        }
        
        self.myTableView.reloadData()
    }
}
