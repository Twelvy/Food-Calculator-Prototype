//
//  FoodDatabase.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/12/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import Foundation

class FoodDatabase {
    private var foods: [Int: FoodInformation]
    
    init() {
        foods = [Int: FoodInformation]()
        foods[0] = FoodInformation(foodName: "aaa", kcal: 50)
        foods[1] = FoodInformation(foodName: "bbb", kcal: 60)
        foods[2] = FoodInformation(foodName: "ccc", kcal: 70)
        foods[3] = FoodInformation(foodName: "ddd", kcal: 80)
    }
    
    func getFoodCount() -> Int {
        foods.count
    }
    /*
    func getFoodIndices() -> [Int] {
        foods.keys
    }
    */
    func getFoodInformation(index: Int) -> FoodInformation {
        return foods[index]!
    }
    
    func insertFood(name: String, kcal: Float) -> Int {
        //let index: Int = 1000; // TODO: get it from database
        let index: Int = foods.count; // TODO: get it from database
        foods[index] = FoodInformation(foodName: name, kcal: kcal);
        return index
    }
    
    func editFoodKCal(index: Int, kcal: Float) {
        foods[index]?.kCal = kcal
    }
    
    func editFoodName(index: Int, newName: String) {
        foods[index]?.name = newName
    }
}
