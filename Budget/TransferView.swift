import Foundation
import UIKit
import RealmSwift

class TransferView: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let realm = try! Realm()
    
    var categories: [String] = []
    
    var fromSelected: Int = 0
    var toSelected: Int = 0
    
    let defaults = UserDefaults.standard
    
    var presenter: CategoryListViewController? = nil
    
    @IBOutlet weak var transferMoney: UITextField!
    @IBOutlet weak var toPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories.append("To Be Budgeted")
        
        let categoryResults = realm.objects(Category.self)
        for category in categoryResults {
            categories.append(category.title)
        }
    }
    
    public func setStartingSelected(i: Int) {
        toSelected = i + 1
        toPickerView.selectRow(i + 1, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView.tag == 0) {
            fromSelected = row
        } else {
            toSelected = row
        }
    }
    
    @IBAction func onSaveClick(_ sender: Any) {
        let categoryResults = realm.objects(Category.self)
                
        if(fromSelected != 0) {
            fromSelected -= 1
            let fromCategory = Category()
            fromCategory.title = categoryResults[fromSelected].title
            fromCategory.goal = categoryResults[fromSelected].goal
            fromCategory.amount = categoryResults[fromSelected].amount - (transferMoney.text! as NSString).floatValue
            presenter!.update(category: fromCategory, i: fromSelected)
        } else {
            defaults.set(defaults.float(forKey: "ToBeBudgeted") - (transferMoney.text! as NSString).floatValue, forKey: "ToBeBudgeted")
            print("from selected is to be budgeted")
        }
        
        if(toSelected != 0) {
            toSelected -= 1
            let toCategory = Category()
            toCategory.title = categoryResults[toSelected].title
            toCategory.goal = categoryResults[toSelected].goal
            toCategory.amount = categoryResults[toSelected].amount + (transferMoney.text! as NSString).floatValue
            presenter!.update(category: toCategory, i: toSelected)
        } else {
            defaults.set(defaults.float(forKey: "ToBeBudgeted") + (transferMoney.text! as NSString).floatValue, forKey: "ToBeBudgeted")
            print("to selected is to be budgeted")
        }
        
        presenter!.refreshValues()
        
        self.dismiss(animated: true, completion: nil)
    }
}
