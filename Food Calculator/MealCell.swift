//
//  MealCell.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/26/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class MealCell : UITableViewCell {
    
    var mealInfo: MealInfo? = nil
    
    func setInfo(info: MealInfo?) {
        mealInfo = info
        if info == nil {
            textLabel!.text = "error"
            detailTextLabel!.text = "-- g"
        }
        else {
            textLabel!.text = mealInfo!.foodName
            detailTextLabel!.text = String(mealInfo!.weight) + " g"
        }
    }
}
