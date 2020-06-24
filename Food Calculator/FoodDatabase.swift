//
//  FoodDatabase.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/12/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import Foundation
import SQLite3

class FoodDatabase {
    private var db: OpaquePointer?
    private let dbPath = "foodDb.db"
    
    init() {
        let dbFileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent(dbPath)
        
        // connect to database
        if sqlite3_open_v2(dbFileURL.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK {
            createFoodTable()
            createMealTable()
        }
        else {
            print("error when opening database")
        }
        // fill tables
        //insertFood(name: "aaa", kcal: 50)
        //insertFood(name: "bbb", kcal: 60)
        //insertFood(name: "ccc", kcal: 70)
        //insertFood(name: "ddd", kcal: 80)
    }
    
    deinit {
        if db != nil {
            if sqlite3_close_v2(db) != SQLITE_OK {
                print("Error when closing database")
            }
        }
    }
    
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
    
    private func createMealTable() {
        var statement: OpaquePointer? = nil
        let statementStr = """
            CREATE TABLE IF NOT EXISTS Meals (
                Id       INTEGER   PRIMARY KEY AUTOINCREMENT,
                date     DATE      NOT NULL,
                meal     CHAR(1)   NOT NULL,
                foodId   INTEGER   NOT NULL,
                weight   REAL      NOT NULL DEFAULT 0,

                FOREIGN KEY(foodId) REFERENCES Foods(Id),
                CHECK (meal in ('B', 'L', 'D', 'T'))
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
            if sqlite3_bind_int64(statement, 1, sqlite_int64(index)) != SQLITE_OK {
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
}
