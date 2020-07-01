//
//  DailySummaryViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/28/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class DailySummaryViewController : UIViewController {
    
    @IBOutlet weak var breakfastLabel: UILabel!
    @IBOutlet weak var lunchLabel: UILabel!
    @IBOutlet weak var dinnerLabel: UILabel!
    @IBOutlet weak var treatsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    private var mealDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func setup(date: Date?) {
        mealDate = date
    }
    
    func updateView() {
        if mealDate == nil {
            return
        }
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let database = app.foodDatabase
        
        let breakfastCalories = database.calculateCalories(date: mealDate!, mealTime: .Breakfast)
        let lunchCalories = database.calculateCalories(date: mealDate!, mealTime: .Lunch)
        let dinnerCalories = database.calculateCalories(date: mealDate!, mealTime: .Dinner)
        let treatsCalories = database.calculateCalories(date: mealDate!, mealTime: .Treats)
        
        breakfastLabel.text = String(breakfastCalories) + " kcal"
        lunchLabel.text = String(lunchCalories) + " kcal"
        dinnerLabel.text = String(dinnerCalories) + " kcal"
        treatsLabel.text = String(treatsCalories) + " kcal"
        
        totalLabel.text = String(breakfastCalories + lunchCalories + dinnerCalories + treatsCalories) + " kcal"
    }
}
