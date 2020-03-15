//
//  ViewController.swift
//  Budget
//
//  Created by Jesse on 12/28/19.
//  Copyright © 2019 Bennett Apps. All rights reserved.
//
import UIKit
import RealmSwift

class AccountTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    var accountList: Results<Accounts>?
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() { // load up and read data
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        accountList = realm.objects(Accounts.self).sorted(byKeyPath: "date", ascending: false)
        myTableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int // set correct number of rows
    {
        return accountList?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell // set all the titles
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath) as! CategoryTableViewCell
        cell.valueText.text = String(format: "$%.2f", accountList![indexPath.row].balance)
        cell.textLabel?.text = accountList?[indexPath.row].title
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
            let alert = UIAlertController(title: "Edit Account", message: nil, preferredStyle: UIAlertController.Style.alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields![0].placeholder = "Enter a name..."
            alert.textFields![0].text = self.accountList![indexPath.row].title
            alert.textFields![0].autocorrectionType = .yes

            alert.addTextField(configurationHandler: nil)
            alert.textFields![1].placeholder = "Enter starting balance..."
            alert.textFields![1].text = String(self.accountList![indexPath.row].startingBalance)
            alert.textFields![1].keyboardType = .decimalPad
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: {(action) in
                if(alert.textFields![0].hasText) {
                    let newAccount = Accounts()
                    let newStartingBalance = (alert.textFields![1].text! as NSString).floatValue
                    newAccount.title = alert.textFields![0].text!
                    newAccount.balance = self.accountList![indexPath.row].balance - self.accountList![indexPath.row].startingBalance + newStartingBalance
                    newAccount.startingBalance = newStartingBalance
                    self.update(account: newAccount, i: indexPath.row)
                }
            }))
            
            self.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func plusButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "New Account", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.textFields![0].placeholder = "Enter a name..."
        alert.textFields![0].autocorrectionType = .yes
        
        alert.addTextField(configurationHandler: nil)
        alert.textFields![1].placeholder = "Enter starting balance..."
        alert.textFields![1].keyboardType = .decimalPad
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Create", style: UIAlertAction.Style.default, handler: {(action) in
            if(alert.textFields![0].hasText) {
                let newAccount = Accounts()
                newAccount.title = alert.textFields![0].text!
                newAccount.balance = (alert.textFields![1].text! as NSString).floatValue
                newAccount.startingBalance = newAccount.balance
                self.save(account: newAccount)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func delete(row: Int) { // delete row, and move the balance up to "to be budgeted"
        let alert = UIAlertController(title: "Delete?", message: "Account will be Deleted and the Balance will be subtracted from total", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: {(action) in
            self.defaults.set(self.defaults.float(forKey: "ToBeBudgeted") - (self.accountList?[row].balance)!, forKey: "ToBeBudgeted")
            try? self.realm.write ({
                self.realm.delete((self.accountList?[row])!)
                self.accountList = self.realm.objects(Accounts.self).sorted(byKeyPath: "date", ascending: false)
            })
            self.myTableView.reloadData()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func save(account: Accounts) { // save row
        do {
            try realm.write {
                let newAccount = Accounts()
                newAccount.title = account.title
                newAccount.balance = account.balance
                newAccount.startingBalance = account.startingBalance
                realm.add(newAccount)
                defaults.set(defaults.float(forKey: "ToBeBudgeted") + account.balance, forKey: "ToBeBudgeted")
            }
        } catch {
            print("Error saving account \(error)")
        }
        
        self.myTableView.reloadData()
    }
    
    func update(account: Accounts, i: Int) { // update row
        do {
            try realm.write {
                accountList![i].title = account.title
                accountList![i].balance = account.balance
                defaults.set(defaults.float(forKey: "ToBeBudgeted") - accountList![i].startingBalance + account.startingBalance, forKey: "ToBeBudgeted")
                accountList![i].startingBalance = account.startingBalance
            }
        } catch {
            print("Error updating account \(error)")
        }
        
        self.myTableView.reloadData()
    }
}
