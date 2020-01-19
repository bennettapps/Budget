//
//  ViewController.swift
//  Budget
//
//  Created by Jesse on 12/28/19.
//  Copyright © 2019 Bennett Apps. All rights reserved.
//

import UIKit

class CategoryListViewController: UITableViewController {
    var list: [String] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = list[indexPath.row]
        
        return cell
    }
    
//    @IBAction func homePlusButtonClicked(_ sender: Any) {
//        createAlert(title: "New Category", message: "")
//    }
//
//    func createAlert (title:String, message:String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
//
//        alert.addTextField(configurationHandler: nil)
//        alert.textFields![0].placeholder = "Enter a name..."
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
//
//        alert.addAction(UIAlertAction(title: "Create", style: UIAlertAction.Style.default, handler: {(action) in
//            if(alert.textFields![0].hasText) {
//                self.list.append(alert.textFields![0].text!)
//                self.myTableView.reloadData()
//            }
//        }))
//
//        self.present(alert, animated: true, completion: nil)
//    }
}
