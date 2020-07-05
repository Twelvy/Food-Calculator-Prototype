//
//  MealViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/26/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class MealViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mealCaloriesLabel: UILabel!
    @IBOutlet weak var mealTableView: UITableView!
    
    private var mealTime: MealTime = .Breakfast
    private var mealDate: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTotalCalories()
    }
    
    private func getDatabase() -> FoodDatabase {
        let app = UIApplication.shared.delegate as! AppDelegate
        return app.foodDatabase
    }
    
    func setup(meal: MealTime, date: Date) {
        mealTime = meal
        mealDate = date
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let database = getDatabase()
        return database.getMealCount(date: mealDate!, time: mealTime)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let mealCell = cell as! MealCell
        let database = getDatabase()
        let info = database.getMealInfo(date: mealDate!, time: mealTime, index: indexPath.row) // needs at least meal key otherwise we cannot delete it
        mealCell.setInfo(info: info)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! MealCell
            let database = getDatabase()
            database.deleteMeal(key: cell.mealInfo!.mealId)
            tableView.deleteRows(at: [indexPath], with: .fade)
            (self.tabBarController as? DailyTabBarController)?.onDailyFoodUpdated()
            updateTotalCalories()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "editWeight" {
            let mealCell = mealTableView.cellForRow(at: mealTableView.indexPathForSelectedRow!) as! MealCell
            return mealCell.mealInfo != nil
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editWeight" {
            let mealCell = mealTableView.cellForRow(at: mealTableView.indexPathForSelectedRow!) as! MealCell
            let controller = segue.destination as! EditWeightViewController
            controller.setMealToEdit(mealCell.mealInfo)
        }
    }
    
    func addMeal(foodId: Int) {
        let database = getDatabase()
        database.addMeal(date: mealDate!, meal: mealTime, foodKey: foodId, weight: 0.0)
        mealTableView?.reloadData()
        (tabBarController as? DailyTabBarController)?.onDailyFoodUpdated()
        updateTotalCalories()
    }
    
    func refresh() {
        mealTableView?.reloadData()
        updateTotalCalories()
    }
    
    private func updateTotalCalories() {
        let database = getDatabase()
        let kcal = database.calculateCalories(date: mealDate!, mealTime: mealTime)
        mealCaloriesLabel?.text = String(kcal) + " kcal"
    }
    
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue) {
        // nothing to do
    }
    
    @IBAction func addMeal(_ unwindSegue: UIStoryboardSegue) {
        guard let src = unwindSegue.source as? ChooseFoodViewController,
            let foodKey = src.selectedFoodKey else {
            return
        }
        addMeal(foodId: foodKey)
    }
    
    @IBAction func unwindToEditWeight(_ unwindSegue: UIStoryboardSegue) {
        refresh()
    }
}
