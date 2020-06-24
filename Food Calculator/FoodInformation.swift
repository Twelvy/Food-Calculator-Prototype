//
//  FoodInformation.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/12/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import Foundation

struct FoodInformation {
    let primaryKey: Int
    var name: String
    var kCal: Float
    
    init(key: Int, foodName: String, kcal: Float) {
        primaryKey = key
        name = foodName
        kCal = kcal
    }
}
