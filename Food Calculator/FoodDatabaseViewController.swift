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
            controller.setFoodId(key: foodCell.foodInfo!.primaryKey)
        }
    }
    
    override func tableView(_ tableview: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableview.cellForRow(at: indexPath) as? FoodCell,
            let foodInfo = cell.foodInfo else {
            return
        }
        
        let alert = UIAlertController(title: "Edit food", message: "Edit food information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            self.editFood(info: foodInfo, foodName: alert.textFields?[0].text, kcal: alert.textFields?[1].text, indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Name"
            textField.text = foodInfo.name
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "kcal for 100 g"
            textField.text = String(foodInfo.kCal)
            textField.keyboardType = .decimalPad
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func editFood(info: FoodInformation, foodName: String?, kcal:String?, indexPath: IndexPath) {
        if foodName == nil || foodName!.isEmpty{
            let alert = UIAlertController(title: "Missing name", message: "Add name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        // parse kCal
        else if kcal == nil || kcal!.isEmpty{
            let alert = UIAlertController(title: "Missing kCal", message: "Add kCal information", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let kCal: Float? = Float(kcal!)
            if kCal == nil {
                let alert = UIAlertController(title: "Wrong kCal", message: "kCal should be a number", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                var reload = false
                if foodName != info.name {
                    database?.editFoodName(key: info.primaryKey, newName: foodName!)
                    reload = true
                }
                if kCal != info.kCal {
                    database?.editFoodKCal(key: info.primaryKey, kcal: kCal!)
                    reload = true
                }
                if reload {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    @IBAction func addFoodAction(_ sender: Any) {
        displayAddFoodAlert(foodName: nil, kcal: nil)
    }
    
    private func displayAddFoodAlert(foodName: String?, kcal: String?) {
        let alert = UIAlertController(title: "Add new food", message: "Enter food information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            self.addFood(foodName: alert.textFields?[0].text, kcal: alert.textFields?[1].text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Name"
            textField.text = foodName
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "kcal for 100 g"
            textField.text = kcal
            textField.keyboardType = .decimalPad
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func addFood(foodName: String?, kcal:String?) {
        if foodName == nil || foodName!.isEmpty {
            let alert = UIAlertController(title: "Missing name", message: "Add name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.displayAddFoodAlert(foodName: foodName, kcal: kcal)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        // parse kCal
        else if kcal == nil || kcal!.isEmpty {
            let alert = UIAlertController(title: "Missing kCal", message: "Add kCal information", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.displayAddFoodAlert(foodName: foodName, kcal: kcal)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let kCal: Float? = Float(kcal!)
            if kCal == nil {
                let alert = UIAlertController(title: "Wrong kCal", message: "kCal should be a number", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.displayAddFoodAlert(foodName: foodName, kcal: kcal)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                database?.insertFood(name: foodName!, kcal: kCal!)
                tableView.reloadData()
            }
        }
    }
}
