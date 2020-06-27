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
    private var mealDate: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.foodDatabase
    }
    
    func setup(meal: MealTime, date: String) {
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
        }
    }
    
    func addMeal(foodId: Int) {
        database?.addMeal(date: mealDate!, meal: mealTime, foodKey: foodId, weight: 0.0)
        tableView.reloadData()
    }
}
