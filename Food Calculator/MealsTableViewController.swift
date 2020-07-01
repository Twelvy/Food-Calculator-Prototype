//
//  MealsTableViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/25/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class MealsTableViewController : UITableViewController {
    
    private var database: FoodDatabase? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.foodDatabase
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return database!.getDayCount()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let date = database!.getMealDate(index: indexPath.row)
        cell.textLabel?.text = date
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let foodCell = tableView.cellForRow(at: indexPath) as! FoodCell
            database?.deleteFood(key: foodCell.foodInfo!.primaryKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            let controller = segue.destination as! DailyTabBarController
            var newDate = sender as? String
            if newDate == nil {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let cell = tableView.cellForRow(at: indexPath)
                    newDate = cell?.textLabel?.text
                }
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let date = formatter.date(from: newDate!)
            controller.setDate(date: date)
        }
    }
    
    @IBAction func addDay(_ sender: Any) {
        let alert = UIAlertController(title: "Choose date", message: "my date", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let year = MealsTableViewController.readInt(text: alert.textFields?[0].text),
                let month = MealsTableViewController.readInt(text: alert.textFields?[1].text),
                let day = MealsTableViewController.readInt(text: alert.textFields?[2].text) else {
                    self.showDateError()
                    return
            }
            let d = DateComponents(calendar: Calendar.current, year: year, month: month, day: day)
            if d.isValidDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let newDate = formatter.string(from: d.date!)
                self.performSegue(withIdentifier: "show", sender: newDate)
            }
            else {
                self.showDateError()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let date = Date()
        let calendar = Calendar.current
        let todayYear = calendar.component(.year, from: date)
        let todayMonth = calendar.component(.month, from: date)
        let todayDay = calendar.component(.day, from: date)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Year"
            textField.text = String(todayYear)
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Month"
            textField.text = String(todayMonth)
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Day"
            textField.text = String(todayDay)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    private static func readInt(text: String?) -> Int? {
        if text == nil || text!.isEmpty {
            return nil
        }
        return Int(text!)
    }
    
    private func showDateError() {
        let alert = UIAlertController(title: "Error in date", message: "input a correct date", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
}
