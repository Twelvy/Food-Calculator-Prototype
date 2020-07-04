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
    @IBOutlet weak var targetCaloriesField: UITextField!
    @IBOutlet weak var extraFoodLabel: UILabel!
    @IBOutlet weak var extraWeightLabel: UILabel!
    @IBOutlet weak var forwardExtraFoodButton: UIButton!
    
    private var mealDate: Date?
    
    private var selectedFood: FoodInformation?
    private var extraWeight: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(DailySummaryViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DailySummaryViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        updateView()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        // test if the textfield will be covered
        let frameInView = self.view.convert(targetCaloriesField.frame, from: targetCaloriesField.superview)
        let targetOffset = keyboardSize.height - (self.view.frame.height - (frameInView.origin.y + frameInView.height + 20))
        
        if targetOffset > 0 {
            // move the root view up by the offset
            self.view.frame.origin.y = 0 - targetOffset
        }
        else {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
    }
    
    private func getDatabase() -> FoodDatabase {
        let app = UIApplication.shared.delegate as! AppDelegate
        return app.foodDatabase
    }
    
    func setup(date: Date?) {
        mealDate = date
    }
    
    func updateView() {
        if mealDate == nil {
            return
        }
        
        let database = getDatabase()
        
        let breakfastCalories = database.calculateCalories(date: mealDate!, mealTime: .Breakfast)
        let lunchCalories = database.calculateCalories(date: mealDate!, mealTime: .Lunch)
        let dinnerCalories = database.calculateCalories(date: mealDate!, mealTime: .Dinner)
        let treatsCalories = database.calculateCalories(date: mealDate!, mealTime: .Treats)
        
        breakfastLabel?.text = String(breakfastCalories) + " kcal"
        lunchLabel?.text = String(lunchCalories) + " kcal"
        dinnerLabel?.text = String(dinnerCalories) + " kcal"
        treatsLabel?.text = String(treatsCalories) + " kcal"
        
        let totalCalories = breakfastCalories + lunchCalories + dinnerCalories + treatsCalories
        totalLabel?.text = String(totalCalories) + " kcal"
        
        if selectedFood == nil {
            extraFoodLabel?.text = nil
            extraWeightLabel?.text = "--"
            forwardExtraFoodButton?.isEnabled = false
        }
        else {
            extraFoodLabel?.text = selectedFood!.name
            
            let targetCalories = parseCalories()
            if targetCalories == nil {
                extraWeightLabel?.text = "--"
                forwardExtraFoodButton?.isEnabled = false
            }
            else if targetCalories! < totalCalories {
                extraWeightLabel?.text = "enough for today!"
                forwardExtraFoodButton?.isEnabled = false
            }
            else if selectedFood!.kCal <= 0.0 {
                extraWeightLabel?.text = "non nutritive food!"
                forwardExtraFoodButton?.isEnabled = false
            }
            else {
                extraWeight = (targetCalories! - totalCalories) / selectedFood!.kCal
                extraWeightLabel?.text = String(extraWeight) + " g"
                forwardExtraFoodButton?.isEnabled = true
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        updateView()
        return true
    }
    
    private func parseCalories() -> Float? {
        if targetCaloriesField != nil && targetCaloriesField.hasText && targetCaloriesField.text != nil && !targetCaloriesField.text!.isEmpty {
            return Float(targetCaloriesField.text!)
        }
        return nil
    }
    
    @IBAction func addMeal(_ unwindSegue: UIStoryboardSegue) {
        guard let src = unwindSegue.source as? ChooseFoodViewController,
            let foodKey = src.selectedFoodKey else {
            return
        }
        
        let database = getDatabase()
        selectedFood = database.getFoodInformation(key: foodKey)
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveFood(_ mealTime: MealTime) {
        let database = getDatabase()
        database.addMeal(date: mealDate!, meal: mealTime, foodKey: selectedFood!.primaryKey, weight: extraWeight)
        selectedFood = nil
        updateView()
        (tabBarController as? DailyTabBarController)?.refreshMeal(mealTime)
    }
    
    func onDailyFoodUpdated() {
        updateView()
    }
}
