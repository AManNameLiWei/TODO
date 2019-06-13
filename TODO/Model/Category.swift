//
//  Category.swift
//  TODO
//
//  Created by 厉威 on 2019/6/13.
//  Copyright © 2019 厉威. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    //dynamic代表在应用运行时可以监控属性值变化
    @objc dynamic var name: String = ""
    
    //关联Item类，一对多的关系
    let items = List<Item>()
    
}
