//
//  MealCell.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/26/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class MealCell : UITableViewCell {
    
    var mealKey: Int = -1
    var foodKey: Int = -1
    var mealWeight: Float = 0
    
    func setInfo(info: MealInfo?) {
        if info == nil {
            textLabel!.text = "error"
            detailTextLabel!.text = "-- g"
        }
        else {
            mealKey = info!.mealId
            foodKey = info!.foodId
            mealWeight = info!.weight
            textLabel!.text = info!.foodName
            detailTextLabel!.text = String(mealWeight) + " g"
        }
    }
}
