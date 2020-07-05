//
//  EditFoodViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/14/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class EditFoodViewController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var caloriesField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    private var lastSelectedTextfield: UITextField? = nil
    
    private var database: FoodDatabase? = nil;
    private var foodInfo: FoodInformation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.foodDatabase
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditFoodViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditFoodViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        if foodInfo != nil {
            nameField.text = foodInfo!.name
            caloriesField.text = String(foodInfo!.kCal)
            editButton.setTitle("Edit", for: .normal)
            titleLabel.text = "Edit food information"
        }
        else {
            editButton.setTitle("Add", for: .normal)
            titleLabel.text = "Add new food"
        }
    }
    
    func setFoodToEdit(_ f: FoodInformation?) {
        foodInfo = f
    }
    
    // MARK: - Methods to move view when keyboard appears
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        lastSelectedTextfield = textField
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == lastSelectedTextfield {
            lastSelectedTextfield = nil
        }
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        guard let tf = lastSelectedTextfield else {
            return
        }
        
        // test if the textfield will be covered
        let frameInView = self.view.convert(tf.frame, from: tf.superview)
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
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            // parse calories
            if !caloriesField.hasText {
                let alert = UIAlertController(title: "Missing calories", message: "Add calories information", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            
            guard let calories = Float(caloriesField.text!) else {
                let alert = UIAlertController(title: "Wrong calories", message: "calories should be a number", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            
            if calories < 0.0 {
                let alert = UIAlertController(title: "Negative calories", message: "Calories should be positive", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
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
