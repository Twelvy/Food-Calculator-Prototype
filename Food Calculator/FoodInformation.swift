//
//  FoodInformation.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/12/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import Foundation

struct FoodInformation {
    var name: String
    var kCal: Float
    
    init(foodName: String, kcal: Float) {
        name = foodName
        kCal = kcal
    }
}
