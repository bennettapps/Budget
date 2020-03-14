//
//  Transactions.swift
//  Budget
//
//  Created by Jesse on 2/6/20.
//  Copyright © 2020 Bennett Apps. All rights reserved.
//

import Foundation
import RealmSwift

// this stores:
// the title/payee
// the amount, positive or negative
// the account it's pulling from
// the category it's pulling from
// the first two are really easy, very similar to categories and accounts
// but the last two are a little more tricky
// you need to store some sort of connection to the category and account
// and then you have to grab it and change the balance accordingly
// i was just using indexes (numbers)
// but that's a trash idea bc like they could change at any time when something is deleted
// so i need a new strat
// maybe store the date of the category and acc
// then pull it from the list


class Transactions: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var amount: Float = 0.00
    @objc dynamic var date: NSDate? = NSDate()
    @objc dynamic var toBeBudgeted: Bool = false
    @objc dynamic var category: NSDate? = NSDate()
    @objc dynamic var account: NSDate? = NSDate()
}
