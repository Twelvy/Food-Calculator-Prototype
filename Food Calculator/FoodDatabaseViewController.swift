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
            database?.deleteFood(key: foodCell.primaryKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue) {
    }

    @IBAction func foodAdded(_ unwindSegue: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFood" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddFoodViewController
            controller.setDatabase(database: database!)
        }
        else if segue.identifier == "editFood" {
            let controller = segue.destination as! EditFoodViewController
            controller.setDatabase(database: database!)
            let indexPath = tableView.indexPathForSelectedRow!
            let cell = tableView.cellForRow(at: indexPath)
            let foodCell = cell as! FoodCell
            controller.setFoodId(key: foodCell.primaryKey)
        }
    }
    
    @IBAction func addFood(_ sender: Any) {
        let alert = UIAlertController(title: "Add new food", message: "Fill information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Name"
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "kcal for 100 g"
        })
        self.present(alert, animated: true, completion: nil)
    }
}
