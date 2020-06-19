//
//  AddFoodViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/14/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class AddFoodViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var kCalField: UITextField!
    
    private var database: FoodDatabase? = nil;
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func setDatabase(database d:FoodDatabase) {
        database = d
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "cancel" {
            return true
        }
        if identifier == "addFood" {
            if !nameField.hasText {
                let alert = UIAlertController(title: "Missing name", message: "Add name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            // parse kCal
            if !kCalField.hasText {
                let alert = UIAlertController(title: "Missing kCal", message: "Add kCal information", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            let kCal: Float? = Float(kCalField.text!)
            if kCal == nil {
                let alert = UIAlertController(title: "Wrong kCal", message: "kCal should be a number", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            
            database?.insertFood(name: nameField.text!, kcal: kCal!)
            return true
        }
        return false
    }
}
