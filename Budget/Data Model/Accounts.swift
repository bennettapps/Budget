//
//  Accounts.swift
//  Budget
//
//  Created by Jesse on 2/6/20.
//  Copyright © 2020 Bennett Apps. All rights reserved.
//

import Foundation
import RealmSwift

class Accounts: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var startingBalance: Float = 0.00
    @objc dynamic var balance: Float = 0.00
    @objc dynamic var date: NSDate = NSDate()
}
