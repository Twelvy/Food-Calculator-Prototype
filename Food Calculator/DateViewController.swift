//
//  DateViewController.swift
//  Food Calculator
//
//  Created by Aurélien Sérandour on 6/30/20.
//  Copyright © 2020 Aurélien Sérandour. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateViewController : UIViewController {
    
    private var database: FoodDatabase? = nil;
    
    @IBOutlet weak var monthView: JTACMonthView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.shared.delegate as! AppDelegate
        database = app.foodDatabase
    }
    
    //private var selectedDate: Date?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            let cellState = monthView.cellStateFromIndexPath(monthView.indexPathsForSelectedItems![0])
            let controller = segue.destination as! DailyTabBarController
            controller.setDate(date: cellState.date)
        }
    }
}

extension DateViewController: JTACMonthViewDataSource {
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        //let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd"
        //let startDate = formatter.date(from: "2020-01-01")!
        //let endDate = Date()
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month], from: now)
        let dc = DateComponents(calendar: Calendar.current, year: components.year, month: components.month! - 1, day: 1)
        
        let startDate = dc.date!
        
        let dc2 = DateComponents(calendar: Calendar.current, year: components.year, month: components.month! + 1, day: 1)
        let endDate = dc2.date!
        
        return ConfigurationParameters(startDate: startDate, endDate: endDate, generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow, firstDayOfWeek: .monday)
    }
}

extension DateViewController: JTACMonthViewDelegate {
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        cell.dateLabel.text = cellState.text
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = .none
        }
        else {
            cell.dateLabel.textColor = .secondaryLabel
        }
        
        if database!.getMealCount(date: cellState.date) > 0 {
            cell.indicator.isHidden = false
        }
        else {
            cell.indicator.isHidden = true
        }
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DateCell
        cell.dateLabel.text = cellState.text
    }
}
