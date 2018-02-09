//
//  Category.swift
//  Todoey
//
//  Created by Marcelo Rodriguez on 2/8/18.
//  Copyright © 2018 Marcelo Rodriguez. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
	
    @objc dynamic var name 		: String = ""
	@objc dynamic var colorHex 		: String = ""

    let items 					= List<Item>()
}
