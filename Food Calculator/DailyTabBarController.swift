//
//  DailyTabBarController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/25/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class DailyTabBarController : UITabBarController {
    
    var mealDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "MMMM d yyyy"
        self.navigationItem.title = formatter.string(from: mealDate!)
        
        if tabBar.items != nil {
            let count = tabBar.items!.count
            if count > 0 {
                tabBar.items![0].image = UIImage(systemName: "sunrise")
                tabBar.items![0].selectedImage = UIImage(systemName: "sunrise.fill")
                tabBar.items![0].title = "Breakfast"
            }
            if count > 1 {
                tabBar.items![1].image = UIImage(systemName: "sun.max")
                tabBar.items![1].selectedImage = UIImage(systemName: "sun.max.fill")
                tabBar.items![1].title = "Lunch"
            }
            if count > 2 {
                tabBar.items![2].image = UIImage(systemName: "moon")
                tabBar.items![2].selectedImage = UIImage(systemName: "moon.fill")
                tabBar.items![2].title = "Dinner"
            }
            if count > 3 {
                tabBar.items![3].image = UIImage(systemName: "star.circle")
                tabBar.items![3].selectedImage = UIImage(systemName: "star.circle.fill")
                tabBar.items![3].title = "Treats"
            }
        }
        
        if viewControllers != nil {
            let count = viewControllers!.count
            if count > 0 {
                (viewControllers![0] as! MealViewController).setup(meal: .Breakfast, date: mealDate!)
            }
            if count > 1 {
                (viewControllers![1] as! MealViewController).setup(meal: .Lunch, date: mealDate!)
            }
            if count > 2 {
                (viewControllers![2] as! MealViewController).setup(meal: .Dinner, date: mealDate!)
            }
            if count > 3 {
                (viewControllers![3] as! MealViewController).setup(meal: .Treats, date: mealDate!)
            }
            if count > 4 {
                (viewControllers![4] as! DailySummaryViewController).setup(date: mealDate!)
            }
        }
    }
    
    func setDate(date: Date?) {
        mealDate = date
    }
    
    func onDailyFoodUpdated() {
        (viewControllers![4] as! DailySummaryViewController).onDailyFoodUpdated()
    }
    
    func refreshMeal(_ mealTime: MealTime) {
        let index = Int(mealTime.rawValue)
        (viewControllers![index] as! MealViewController).refresh()
    }
}
