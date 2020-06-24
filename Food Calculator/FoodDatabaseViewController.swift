//
//  FoodDatabaseViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/12/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit

class FoodDatabaseViewController : UITableViewController {
    
    private var database: FoodDatabase? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.foodDatabase
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return database!.getFoodCount()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let foodCell = cell as! FoodCell
        let food = database!.getFoodInformation(index: indexPath.row)
        if food == nil {
            cell.textLabel!.text = "error"
        }
        else {
            cell.textLabel!.text = food!.name
            foodCell.primaryKey = food!.primaryKey
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let foodCell = tableView.cellForRow(at: indexPath) as! FoodCell
            database?.deleteFood(key: foodCell.primaryKey)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    @IBAction func cancel(_ unwindSegue: UIStoryboardSegue) {
    }

    @IBAction func foodAdded(_ unwindSegue: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addFood" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddFoodViewController
            controller.setDatabase(database: database!)
        }
        else if segue.identifier == "editFood" {
            
        }
    }
}
