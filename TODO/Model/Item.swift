//
//  Item.swift
//  TODO
//
//  Created by 厉威 on 2019/6/13.
//  Copyright © 2019 厉威. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var date: Date?//用于保存item创建的时间
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
