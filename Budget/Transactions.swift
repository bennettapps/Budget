//
//  Transactions.swift
//  Budget
//
//  Created by Jesse on 2/6/20.
//  Copyright © 2020 Bennett Apps. All rights reserved.
//

import Foundation
import RealmSwift

class Transactions: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var amount: Float = 0.00
    @objc dynamic var date: NSDate? = NSDate()
    @objc dynamic var toBeBudgeted: Bool = false
    @objc dynamic var category: NSDate? = NSDate()
    @objc dynamic var account: NSDate? = NSDate()
}
