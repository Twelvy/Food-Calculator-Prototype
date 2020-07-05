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
    
    func tableView(_ tableview: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mealCell = tableview.cellForRow(at: indexPath) as! MealCell
        let alert = UIAlertController(title: "Edit weight", message: "Change the weight of the food", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Edit", style: .destructive, handler: { _ in
            guard let txt = alert.textFields?[0].text else {
                return
            }
            // parse txt
            guard let newWeight = Float(txt) else {
                return
            }
            if mealCell.mealInfo!.weight != newWeight {
                // update weight
                let database = self.getDatabase()
                database.editMeal(key: mealCell.mealInfo!.mealId, weight: newWeight)
                
                // reload cell
                self.mealTableView?.reloadRows(at: [indexPath], with: .automatic)
                (self.tabBarController as? DailyTabBarController)?.onDailyFoodUpdated()
                self.updateTotalCalories()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = String(mealCell.mealInfo!.weight)
            textField.keyboardType = .decimalPad
        })
        self.present(alert, animated: true, completion: nil)
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
}
