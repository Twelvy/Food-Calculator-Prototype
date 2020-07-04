//
//  EditFoodViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/14/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class EditFoodViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var caloriesField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    private var database: FoodDatabase? = nil;
    private var foodInfo: FoodInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.foodDatabase
        
        if foodInfo != nil {
            nameField.text = foodInfo!.name
            caloriesField.text = String(foodInfo!.kCal)
            editButton.setTitle("Edit", for: .normal)
        }
        else {
            editButton.setTitle("Add", for: .normal)
        }
    }
    
    func setFoodToEdit(_ f: FoodInformation?) {
        foodInfo = f
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "cancel" {
            return true
        }
        if identifier == "editFood" {
            if !nameField.hasText {
                let alert = UIAlertController(title: "Missing name", message: "Add name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            // parse calories
            if !caloriesField.hasText {
                let alert = UIAlertController(title: "Missing calories", message: "Add calories information", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            
            guard let calories = Float(caloriesField.text!) else {
                let alert = UIAlertController(title: "Wrong calories", message: "calories should be a number", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            
            if calories < 0.0 {
                let alert = UIAlertController(title: "Negative calories", message: "Calories should be postive", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            
            if foodInfo == nil {
                database?.insertFood(name: nameField.text!, kcal: calories)
            }
            else {
                if nameField!.text != foodInfo!.name {
                    database?.editFoodName(key: foodInfo!.primaryKey, newName: nameField.text!)
                }
                if calories != foodInfo!.kCal {
                    database?.editFoodKCal(key: foodInfo!.primaryKey, kcal: calories)
                }
            }
            return true
        }
        return false
    }
}
