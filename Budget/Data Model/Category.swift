//
//  Category.swift
//  Budget
//
//  Created by Jesse on 1/21/20.
//  Copyright © 2020 Bennett Apps. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var amount: Int = 0
}
