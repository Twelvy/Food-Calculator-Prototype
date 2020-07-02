//
//  DailySummaryViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/28/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class DailySummaryViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var breakfastLabel: UILabel!
    @IBOutlet weak var lunchLabel: UILabel!
    @IBOutlet weak var dinnerLabel: UILabel!
    @IBOutlet weak var treatsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var extraFoodLabel: UILabel!
    @IBOutlet weak var extraFoodWeightField: UITextField!
    @IBOutlet weak var newTotalLabel: UILabel!
    @IBOutlet weak var forwardExtraFoodButton: UIButton!
    
    private var mealDate: Date?
    
    private var selectedFood: FoodInformation?
    
    private var database: FoodDatabase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.foodDatabase
        updateView()
    }
    
    func setup(date: Date?) {
        mealDate = date
    }
    
    func updateView() {
        if mealDate == nil {
            return
        }
        
        let breakfastCalories = database!.calculateCalories(date: mealDate!, mealTime: .Breakfast)
        let lunchCalories = database!.calculateCalories(date: mealDate!, mealTime: .Lunch)
        let dinnerCalories = database!.calculateCalories(date: mealDate!, mealTime: .Dinner)
        let treatsCalories = database!.calculateCalories(date: mealDate!, mealTime: .Treats)
        
        breakfastLabel.text = String(breakfastCalories) + " kcal"
        lunchLabel.text = String(lunchCalories) + " kcal"
        dinnerLabel.text = String(dinnerCalories) + " kcal"
        treatsLabel.text = String(treatsCalories) + " kcal"
        
        let totalCalories = breakfastCalories + lunchCalories + dinnerCalories + treatsCalories
        totalLabel.text = String(totalCalories) + " kcal"
        
        if selectedFood == nil {
            extraFoodLabel.text = nil
            extraFoodWeightField.text = nil
            newTotalLabel.text = totalLabel.text
            forwardExtraFoodButton.isEnabled = false
        }
        else {
            extraFoodLabel.text = selectedFood!.name
            newTotalLabel.text = totalLabel.text
            
            let w = parseWeight()
            let extraCalories = selectedFood!.kCal * w
            let newTotalCalories = totalCalories + extraCalories
            newTotalLabel.text = String(newTotalCalories) + " kcal"
            forwardExtraFoodButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        updateView()
        return true
    }
    
    private func parseWeight() -> Float {
        if extraFoodWeightField.hasText && extraFoodWeightField.text != nil && !extraFoodWeightField.text!.isEmpty {
            let weight = Float(extraFoodWeightField.text!)
            if weight != nil {
                return weight!
            }
        }
        return 0
    }
    
    func setExtraFood(foodId: Int) {
        selectedFood = database?.getFoodInformation(key: foodId)
        updateView()
    }
    
    @IBAction func forwardExtraFood(_ sender: Any) {
        let alert = UIAlertController(title: "Save food", message: "Choose meal", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Breakfast", style: .default, handler: { _ in
            self.saveFood(.Breakfast)
        }))
        alert.addAction(UIAlertAction(title: "Lunch", style: .default, handler: { _ in
            self.saveFood(.Lunch)
        }))
        alert.addAction(UIAlertAction(title: "Dinner", style: .default, handler: { _ in
            self.saveFood(.Dinner)
        }))
        alert.addAction(UIAlertAction(title: "Treats", style: .default, handler: { _ in
            self.saveFood(.Treats)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveFood(_ mealTime: MealTime) {
        database!.addMeal(date: mealDate!, meal: mealTime, foodKey: selectedFood!.primaryKey, weight: parseWeight())
        selectedFood = nil
        updateView()
        (tabBarController as? DailyTabBarController)?.refreshMeal(mealTime)
    }
    
    func onDailyFoodUpdated() {
        updateView()
    }
}
