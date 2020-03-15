//
//  ViewController.swift
//  Budget
//
//  Created by Jesse on 12/28/19.
//  Copyright © 2019 Bennett Apps. All rights reserved.
//
import UIKit
import RealmSwift

// this will just map the values of everythig to the list and let u edit them. simple! :(

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
            let objects = realm.objects(Transactions.self)
            
            if(objects.count > 0) {
                transactionList = objects.sorted(byKeyPath: "date", ascending: false)
            }
            myTableView.reloadData()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int // set correct number of rows
    {
        return transactionList?.count ?? 0
    }
    
    func findCategoryByDate(date: NSDate) -> Category? {
        let categories = realm.objects(Category.self)
        for c in categories {
            if(c.date == date) {
                return (c)
            }
        }
        return nil
    }
    
    func findAccountByDate(date: NSDate) -> Accounts? {
        let accounts = realm.objects(Accounts.self)
        for a in accounts {
            if(a.date == date) {
                return a
            }
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell // set all the titles
    {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        let transaction = transactionList![indexPath.row]
        
        cell.dollarText.text = String(format: "$%.2f", transaction.amount)
        cell.textLabel?.text = transaction.title
        
        if(!transaction.toBeBudgeted) {
            let category = findCategoryByDate(date: transaction.category!)
                        
            cell.categoryText.text = category?.title ?? "DELETED"
        } else {
            cell.categoryText.text = "To Be Budgeted"
        }
        
        let account = findAccountByDate(date: transaction.account!)
        cell.accountText.text = account?.title ?? "DELETED"
        
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) // delete by swiping
    {
        if(editingStyle == UITableViewCell.EditingStyle.delete)
        {
            self.deleteRow(row: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // selected row
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            self.deleteRow(row: indexPath.row)
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
            
            let categories = self.realm.objects(Category.self).sorted(byKeyPath: "date", ascending: false)
            let accounts = self.realm.objects(Accounts.self).sorted(byKeyPath: "date", ascending: false)

            var category = 1
            var account = 0
            for c in categories {
                print(category)
                if(c.date == self.transactionList![indexPath.row].category) {
                    print("found it!")
                    break
                }
                category += 1
            }
            
            if(category > categories.count) {
                category = 0
            }
            
            for a in accounts {
                if(a.date == self.transactionList![indexPath.row].account) {
                    break
                }
                account += 1
            }
                    
            pickerView.setStartingSelected(category: category, account: account)
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
    
    func deleteRow(row: Int) { // delete row, and move the balance up to "to be budgeted"
        let alert = UIAlertController(title: "Delete?", message: "Transaction will be Deleted and the Balance will be returned", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: {(action) in
            let balance = self.transactionList?[row].amount
            let transaction = self.transactionList![row]
            try? self.realm.write ({
                if(!transaction.toBeBudgeted) {
                    if(transaction.category != nil) {
                        let category = self.findCategoryByDate(date: transaction.category!)
                        category?.amount -= balance!
                    }
                } else {
                    self.defaults.set(self.defaults.float(forKey: "ToBeBudgeted") - balance!, forKey: "ToBeBudgeted")
                }
                
                if(transaction.account != nil) {
                    self.findAccountByDate(date: transaction.account!)?.balance -= balance!
                }
            })
            
            try? self.realm.write ({
                self.realm.delete((self.transactionList?[row])!)
                self.transactionList = self.realm.objects(Transactions.self).sorted(byKeyPath: "date", ascending: false)
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
                newTransaction.toBeBudgeted = transaction.toBeBudgeted
                realm.add(newTransaction)
            }
            
            if(!transaction.toBeBudgeted) {
                try realm.write {
                    findCategoryByDate(date: transaction.category!)?.amount += transaction.amount
                }
            } else {
                defaults.set(defaults.float(forKey: "ToBeBudgeted") + transaction.amount, forKey: "ToBeBudgeted")
            }
            
            try realm.write {
                findAccountByDate(date: transaction.account!)?.balance += transaction.amount
            }
        } catch {
            print("Error saving transaction \(error)")
        }
        
        transactionList = realm.objects(Transactions.self).sorted(byKeyPath: "date", ascending: false)
        self.myTableView.reloadData()
    }
    
    func update(transaction: Transactions, i: Int) { // update row
        do {
            let balance = self.transactionList?[i].amount
            let oldTransaction = self.transactionList![i]
            try? self.realm.write ({
                if(!oldTransaction.toBeBudgeted) {
                    if(oldTransaction.category != nil) {
                        let category = self.findCategoryByDate(date: oldTransaction.category!)
                        category?.amount -= balance!
                    }
                } else {
                    self.defaults.set(self.defaults.float(forKey: "ToBeBudgeted") - balance!, forKey: "ToBeBudgeted")
                }
                
                if(oldTransaction.account != nil) {
                    self.findAccountByDate(date: oldTransaction.account!)?.balance -= balance!
                }
            })
            
            let newBalance = transaction.amount
            try? self.realm.write ({
                if(!oldTransaction.toBeBudgeted) {
                    if(oldTransaction.category != nil) {
                        let category = self.findCategoryByDate(date: oldTransaction.category!)
                        category?.amount += newBalance
                    }
                } else {
                    self.defaults.set(self.defaults.float(forKey: "ToBeBudgeted") + newBalance, forKey: "ToBeBudgeted")
                }
                
                if(oldTransaction.account != nil) {
                    self.findAccountByDate(date: oldTransaction.account!)?.balance += newBalance
                }
            })
            
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
