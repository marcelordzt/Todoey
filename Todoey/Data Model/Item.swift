//
//  Item.swift
//  Todoey
//
//  Created by Marcelo Rodriguez on 2/8/18.
//  Copyright © 2018 Marcelo Rodriguez. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
