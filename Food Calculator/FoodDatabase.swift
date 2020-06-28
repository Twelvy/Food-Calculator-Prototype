//
//  FoodDatabase.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/12/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import Foundation
import SQLite3

enum MealTime : Int32 {
    case Breakfast = 0
    case Lunch = 1
    case Dinner = 2
    case Treats = 3
}

struct MealInfo {
    var mealId:Int = -1
    var foodId: Int = -1
    var foodName: String? = nil
    var weight: Float = 0.0
}

class FoodDatabase {
    private var db: OpaquePointer?
    private let dbPath = "foodDb.db"
    
    init() {
        let dbFileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent(dbPath)
        
        // connect to database
        if sqlite3_open_v2(dbFileURL.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK {
            createFoodTable()
                //clearMealTable()
            createMealTable()
        }
        else {
            print("error when opening database")
        }
        // fill tables
        //insertFood(name: "sweet potato", kcal: 50)
        //insertFood(name: "croquette", kcal: 60)
        //insertFood(name: "fish", kcal: 70)
        //insertFood(name: "carrot", kcal: 80)
        
        //addMeal(date: "2020-01-01", meal: .Breakfast, foodKey: 1, weight: 100)
        //addMeal(date: "2020-01-01", meal: .Breakfast, foodKey: 2, weight: 50)
        //addMeal(date: "2020-01-01", meal: .Dinner, foodKey: 3, weight: 70)
        //addMeal(date: "2020-01-02", meal: .Lunch, foodKey: 4, weight: 100)
    }
    
    deinit {
        if db != nil {
            if sqlite3_close_v2(db) != SQLITE_OK {
                print("Error when closing database")
            }
        }
    }
    
    // MARK: - Food database
    
    private func createFoodTable() {
        var statement: OpaquePointer? = nil
        let statementStr = """
            CREATE TABLE IF NOT EXISTS Foods (
                Id     INTEGER    PRIMARY KEY AUTOINCREMENT,
                name   TINYTEXT   NOT NULL,
                kcal   REAL       NOT NULL DEFAULT 0,

                CHECK (length(name) > 0)
            );
            """
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Foods table created")
            }
            else {
                print("Foods table couldn't be created")
            }
        }
        else {
            print("Error when creating Foods table")
        }
        sqlite3_finalize(statement)
    }
    
    private func clearMealTable() {
        var statement: OpaquePointer? = nil
        let statementStr = "DROP TABLE Meals;"
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Meals table created")
            }
            else {
                print("Meals table couldn't be created")
            }
        }
        else {
            print("Error when creating Meals table")
        }
        sqlite3_finalize(statement)
        
        // TODO: index
    }
    
    private func createMealTable() {
        var statement: OpaquePointer? = nil
        let statementStr = """
            CREATE TABLE IF NOT EXISTS Meals (
                Id       INTEGER   PRIMARY KEY AUTOINCREMENT,
                date     DATE      NOT NULL,
                meal     INTEGER   NOT NULL,
                foodId   INTEGER   NOT NULL,
                weight   REAL      NOT NULL DEFAULT 0,

                FOREIGN KEY(foodId) REFERENCES Foods(Id),
                CHECK (meal>=0 AND meal<4)
            );
            """
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Meals table created")
            }
            else {
                print("Meals table couldn't be created")
            }
        }
        else {
            print("Error when creating Meals table")
        }
        sqlite3_finalize(statement)
        
        // TODO: index
    }
    
    func getFoodCount() -> Int {
        var statement: OpaquePointer? = nil
        let statementStr = """
            SELECT COUNT(*)
            FROM Foods;
        """
        var count: Int = -1
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let count32: Int32 = sqlite3_column_int(statement, 0)
                count = Int(count32)
            }
            else {
                print("Foods couldn't be counted")
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
        
        return count
    }
    
    func getFoodInformation(index: Int) -> FoodInformation? {
        var statement: OpaquePointer? = nil
        let statementStr = """
            SELECT
                Id,
                name,
                kcal
            FROM Foods
            ORDER BY
                Id ASC
            LIMIT 1
            OFFSET ?;
            """
        var success = false
        var key: Int = -1
        var name: String? = nil
        var kCal: Float = 0
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_int(statement, 1, Int32(index)) != SQLITE_OK {
                print("Error when binding index")
            }
            else {
                if sqlite3_step(statement) == SQLITE_ROW {
                    key = Int(sqlite3_column_int64(statement, 0))
                    name = String(cString: sqlite3_column_text(statement, 1))
                    kCal = Float(sqlite3_column_double(statement, 2))
                    success = true
                }
                else {
                    print("Failed to get row")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
        
        if success {
            return FoodInformation(key: key, foodName: name!, kcal: kCal)
        }
        else {
            return nil
        }
    }
 
    func getFoodInformation(key: Int) -> FoodInformation? {
        var statement: OpaquePointer? = nil
        let statementStr = """
            SELECT
                name,
                kcal
            FROM Foods
            WHERE Id=?;
            """
        var success = false
        var name: String? = nil
        var kCal: Float = 0
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_int64(statement, 1, sqlite_int64(key)) != SQLITE_OK {
                print("Error when binding Id")
            }
            else {
                if sqlite3_step(statement) == SQLITE_ROW {
                    name = String(cString: sqlite3_column_text(statement, 0))
                    kCal = Float(sqlite3_column_double(statement, 1))
                    success = true
                }
                else {
                    print("Failed to get row")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
        
        if success {
            return FoodInformation(key: key, foodName: name!, kcal: kCal)
        }
        else {
            return nil
        }
    }
    
    func insertFood(name: String, kcal: Float) -> Int {
        var statement: OpaquePointer? = nil
        let statementStr = """
            INSERT INTO Foods (
                name,
                kcal
            ) VALUES (
                ?,
                ?
            );
            """
        var newKey: Int = -1
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_text(statement, 1, name, -1, nil) != SQLITE_OK {
                print("Error when binding text")
            }
            else if sqlite3_bind_double(statement, 2, Double(kcal)) != SQLITE_OK {
                print("Error when binding double")
            }
            else {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Food inserted")
                    newKey = Int(sqlite3_last_insert_rowid(db))
                }
                else {
                    print("Failed to insert food")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
        
        return newKey
    }
    
    func deleteFood(key: Int) {
        var statement: OpaquePointer? = nil
        let statementStr = """
            DELETE FROM Foods (
            WHERE Id=?;
            """
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_int64(statement, 1, sqlite3_int64(key)) != SQLITE_OK {
                print("Error when binding Id")
            }
            else {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Food removed")
                }
                else {
                    print("Failed to remove food")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
    }
    
    func editFoodKCal(key: Int, kcal: Float) {
        var statement: OpaquePointer? = nil
        let statementStr = """
            UPDATE Foods SET
                kcal=?
            WHERE Id=?;
            """
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_double(statement, 1, Double(kcal)) != SQLITE_OK {
                print("Error when binding double")
            }
            if sqlite3_bind_int64(statement, 2, sqlite3_int64(key)) != SQLITE_OK {
                print("Error when binding Id")
            }
            else {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Food edited")
                }
                else {
                    print("Failed to remove food")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
    }
    
    func editFoodName(key: Int, newName: String) {
        var statement: OpaquePointer? = nil
        let statementStr = """
            UPDATE Foods SET
                name=?
            WHERE Id=?;
            """
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_text(statement, 1, newName, -1, nil) != SQLITE_OK {
                print("Error when binding text")
            }
            if sqlite3_bind_int64(statement, 2, sqlite3_int64(key)) != SQLITE_OK {
                print("Error when binding Id")
            }
            else {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Food edited")
                }
                else {
                    print("Failed to remove food")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
    }
    
    // MARK: - Meal database
    
    func getDayCount() -> Int {
        var statement: OpaquePointer? = nil
        let statementStr = """
            SELECT COUNT(DISTINCT date)
            FROM Meals;
        """
        var count: Int = -1
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let count32: Int32 = sqlite3_column_int(statement, 0)
                count = Int(count32)
            }
            else {
                print("Days couldn't be counted")
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
        
        return count
    }
    
    func getMealDate(index: Int) -> String? {
        var statement: OpaquePointer? = nil
        let statementStr = """
            SELECT DISTINCT
                date
            FROM Meals
            ORDER BY
                date DESC
            LIMIT 1
            OFFSET ?;
            """
        var date: String? = nil
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_int(statement, 1, Int32(index)) != SQLITE_OK {
                print("Error when binding index")
            }
            else {
                if sqlite3_step(statement) == SQLITE_ROW {
                    date = String(cString: sqlite3_column_text(statement, 0))
                }
                else {
                    print("Failed to get row")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
        
        return date
    }
    
    func getMealCount(date: String, time: MealTime) -> Int {
        var statement: OpaquePointer? = nil
        let statementStr = """
            SELECT COUNT(*)
            FROM Meals
            WHERE date=? AND meal=?;
            """
        var count: Int = 0
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_text(statement, 1, date, -1, nil) != SQLITE_OK {
                print("Error when binding text")
            }
            else if sqlite3_bind_int(statement, 2, time.rawValue) != SQLITE_OK {
                print("Error when binding int")
            }
            else {
                if sqlite3_step(statement) == SQLITE_ROW {
                    let count32: Int32 = sqlite3_column_int(statement, 0)
                    count = Int(count32)
                }
                else {
                    print("Failed to get row")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
        
        return count
    }
    
    func getMealInfo(date: String, time: MealTime, index: Int) -> MealInfo? {
        var statement: OpaquePointer? = nil
        let statementStr = """
            SELECT
                Meals.Id,
                Meals.foodId,
                Foods.name,
                Meals.weight
            FROM Meals
            INNER JOIN Foods ON Meals.foodId=Foods.Id
            WHERE Meals.date=? AND Meals.meal=?
            ORDER BY
                Meals.Id ASC
            LIMIT 1
            OFFSET ?;
            """
        var info: MealInfo? = nil
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_text(statement, 1, date, -1, nil) != SQLITE_OK {
                print("Error when binding text")
            }
            else if sqlite3_bind_int(statement, 2, time.rawValue) != SQLITE_OK {
                print("Error when binding int")
            }
            else if sqlite3_bind_int(statement, 3, Int32(index)) != SQLITE_OK {
                print("Error when binding int")
            }
            else {
                if sqlite3_step(statement) == SQLITE_ROW {
                    info = MealInfo()
                    info!.mealId = Int(sqlite3_column_int64(statement, 0))
                    info!.foodId = Int(sqlite3_column_int64(statement, 1))
                    info!.foodName = String(cString: sqlite3_column_text(statement, 2))
                    info!.weight = Float(sqlite3_column_double(statement, 3))
                }
                else {
                    print("Failed to get row")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
        
        return info
    }
    
    func addMeal(date: String, meal: MealTime, foodKey: Int, weight:Float) {
        var statement: OpaquePointer? = nil
        let statementStr = """
            INSERT INTO Meals (
                date,
                meal,
                foodId,
                weight
            ) VALUES (
                ?,
                ?,
                ?,
                ?
            );
            """
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_text(statement, 1, date, -1, nil) != SQLITE_OK {
                print("Error when binding text")
            }
            else if sqlite3_bind_int(statement, 2, meal.rawValue) != SQLITE_OK {
                print("Error when binding double")
            }
            else if sqlite3_bind_int64(statement, 3, sqlite3_int64(foodKey)) != SQLITE_OK {
                print("Error when binding double")
            }
            else if sqlite3_bind_double(statement, 4, Double(weight)) != SQLITE_OK {
                print("Error when binding double")
            }
            else {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Meal inserted")
                    //newKey = Int(sqlite3_last_insert_rowid(db))
                }
                else {
                    print("Failed to insert food")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
    }
    
    func deleteMeal(key: Int) {
        var statement: OpaquePointer? = nil
        let statementStr = """
            DELETE FROM Meals
            WHERE Id=?;
            """
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_int64(statement, 1, sqlite3_int64(key)) != SQLITE_OK {
                print("Error when binding Id")
            }
            else {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Meal removed")
                }
                else {
                    print("Failed to remove meal")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
    }
    
    func editMeal(key: Int, weight: Float) {
        var statement: OpaquePointer? = nil
        let statementStr = """
            UPDATE Meals SET
                weight=?
            WHERE Id=?;
            """
        if sqlite3_prepare_v2(db, statementStr, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_bind_double(statement, 1, Double(weight)) != SQLITE_OK {
                print("Error when binding double")
            }
            else if sqlite3_bind_int64(statement, 2, sqlite3_int64(key)) != SQLITE_OK {
                print("Error when binding Id")
            }
            else {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Meal edited")
                }
                else {
                    print("Failed to edit meal")
                }
            }
        }
        else {
            print("Error when preparing statement")
        }
        sqlite3_finalize(statement)
    }
    
    // calculate
}
