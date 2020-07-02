//
//  MealViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/26/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class MealViewController : UITableViewController {
    
    private var database: FoodDatabase? = nil;
    private var mealTime: MealTime = .Breakfast
    private var mealDate: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.foodDatabase
    }
    
    func setup(meal: MealTime, date: Date) {
        mealTime = meal
        mealDate = date
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return database!.getMealCount(date: mealDate!, time: mealTime)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let mealCell = cell as! MealCell
        let info = database!.getMealInfo(date: mealDate!, time: mealTime, index: indexPath.row)
        mealCell.setInfo(info: info)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! MealCell
            database?.deleteMeal(key: cell.mealKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
            (self.tabBarController as? DailyTabBarController)?.onDailyFoodUpdated()
        }
    }
    
    override func tableView(_ tableview: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mealCell = tableView.cellForRow(at: indexPath) as! MealCell
        let alert = UIAlertController(title: "Edit weight", message: "Change the weight of the food", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Edit", style: .destructive, handler: { _ in
            guard let txt = alert.textFields?[0].text else {
                return
            }
            // parse txt
            guard let newWeight = Float(txt) else {
                return
            }
            if mealCell.mealWeight != newWeight {
                // update weight
                self.database?.editMeal(key: mealCell.mealKey, weight: newWeight)
                
                // reload cell
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                (self.tabBarController as? DailyTabBarController)?.onDailyFoodUpdated()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = String(mealCell.mealWeight)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func addMeal(foodId: Int) {
        database?.addMeal(date: mealDate!, meal: mealTime, foodKey: foodId, weight: 0.0)
        tableView.reloadData()
        (tabBarController as? DailyTabBarController)?.onDailyFoodUpdated()
    }
    
    func refresh() {
        tableView.reloadData()
    }
}
