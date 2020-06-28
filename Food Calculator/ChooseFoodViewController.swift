//
//  ChooseFoodViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/26/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class ChooseFoodViewController : FoodDatabaseViewControllerBase {
    
    var selectedFoodKey: Int? = nil
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as! FoodCell
        selectedFoodKey = cell.foodInfo!.primaryKey
    }
}
