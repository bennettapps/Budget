//
//  CategoryPickerView.swift
//  Budget
//
//  Created by Jesse on 2/14/20.
//  Copyright © 2020 Bennett Apps. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class CategoryPickerView: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let realm = try! Realm()
    
    var categories: [String] = []
    var accounts: [String] = []
    
    var categorySelected: Int = 0
    var accountSelected: Int = 0
    
    var presenter: TransactionTableViewController? = nil
    var edit: Bool = false
    var i: Int = 0
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var positiveSwitch: UISwitch!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var accountPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories.append("To Be Budgeted")
        let categoryResults = realm.objects(Category.self).sorted(byKeyPath: "date", ascending: false)
        for category in categoryResults {
            categories.append(category.title)
        }
        let accountResults = realm.objects(Accounts.self).sorted(byKeyPath: "date", ascending: false)
        for account in accountResults {
            accounts.append(account.title)
        }
    }
    
    public func setStartingSelected(category: Int, account: Int) {
        categorySelected = category
        accountSelected = account
        categoryPickerView.selectRow(category, inComponent: 0, animated: false)
        accountPickerView.selectRow(account, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 0) {
            return categories.count
        } else {
            return accounts.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView.tag == 0) {
            return categories[row]
        } else {
            return accounts[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 0) {
            categorySelected = row
        } else {
            accountSelected = row
        }
    }
    
    @IBAction func onSaveClicked(_ sender: Any) {
        print("STARTED")
        let transaction = Transactions()
        transaction.title = titleText.text!
        transaction.amount = (amountText.text! as NSString).floatValue
        if(categorySelected != 0) {
            transaction.category = realm.objects(Category.self).sorted(byKeyPath: "date", ascending: false)[categorySelected - 1].date
            print(realm.objects(Category.self).sorted(byKeyPath: "date", ascending: false)[0])
            print(categorySelected)
        } else {
            print("TO BE BUDGETED")
            transaction.toBeBudgeted = true
        }
        
        transaction.account = realm.objects(Accounts.self).sorted(byKeyPath: "date", ascending: false)[accountSelected].date
        
        if(!positiveSwitch.isOn) {
            transaction.amount *= -1
        }
        
        if(edit) {
            presenter!.update(transaction: transaction, i: i)
        } else {
            presenter!.save(transaction: transaction)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
