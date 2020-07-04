//
//  FoodDatabaseViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/12/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class FoodDatabaseViewController : FoodDatabaseViewControllerBase {
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let foodCell = tableView.cellForRow(at: indexPath) as! FoodCell
            database?.deleteFood(key: foodCell.foodInfo!.primaryKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let foodInfo = getFoodInfoAt(indexPath) else {
            return super.tableView(tableView, canEditRowAt: indexPath)
        }
        return !database!.isFoodUsed(foodInfo.primaryKey)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editFood" {
            let controller = segue.destination as! EditFoodViewController
            controller.setFoodToEdit(sender as? FoodInformation)
        }
    }
    
    override func tableView(_ tableview: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableview.cellForRow(at: indexPath) as? FoodCell,
            let foodInfo = cell.foodInfo else {
            return
        }
        performSegue(withIdentifier: "editFood", sender: foodInfo)
    }
    
    @IBAction func unwindToEditFood(_ unwindSegue: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    @IBAction func unwindToCancel(_ unwindSegue: UIStoryboardSegue) {
        guard let selectIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        tableView.deselectRow(at: selectIndexPath, animated: false)
    }
}
