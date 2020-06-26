//
//  FoodCell.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/19/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class FoodCell : UITableViewCell {
    
    var primaryKey: Int = -1
    
    func setInfo(info: FoodInformation?) {
        if info == nil {
            textLabel!.text = "error"
            detailTextLabel!.text = "-- kcal"
        }
        else {
            primaryKey = info!.primaryKey
            textLabel!.text = info!.name
            detailTextLabel!.text = String(Int(info!.kCal)) + " kcal"
        }
    }
}
