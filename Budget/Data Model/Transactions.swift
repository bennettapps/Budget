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
    @objc dynamic var account: Int = 0
    @objc dynamic var category: Int = 0
    @objc dynamic var date: NSDate = NSDate()
}
