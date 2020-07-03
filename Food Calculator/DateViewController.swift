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
        
        monthView.scrollingMode = .nonStopToSection(withResistance: 1.0)
        monthView.scrollToDate(Date(), animateScroll: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            let cellState = monthView.cellStateFromIndexPath(monthView.indexPathsForSelectedItems![0])
            let controller = segue.destination as! DailyTabBarController
            controller.setDate(date: cellState.date)
        }
    }
    
    // TODO: we would like to reload the data when we come BACK to this view.
    // I don't know the method to use
    override func viewWillAppear(_ animated: Bool) {
        monthView.reloadData()
    }
}

private func GetPreviousMonthDate(_ date: Date) -> Date {
    let components: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
    var editedYear = components.year!
    var editedMonth = components.month! - 1
    if editedMonth <= 0 {
        editedMonth = 12
        editedYear -= 1
    }
    let dc = DateComponents(calendar: Calendar.current, year: editedYear, month: editedMonth, day: 1)
    return dc.date!
}

private func GetNextMonthDate(_ date: Date) -> Date {
    let components: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
    var editedYear = components.year!
    var editedMonth = components.month! + 1
    if editedMonth > 12 {
        editedMonth = 1
        editedYear += 1
    }
    let dc = DateComponents(calendar: Calendar.current, year: editedYear, month: editedMonth, day: 1)
    return dc.date!
}

extension DateViewController: JTACMonthViewDataSource {
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let today = Date()
        
        if database == nil {
            let app = UIApplication.shared.delegate as! AppDelegate
            database = app.foodDatabase
        }
        
        let firstDate = database?.getFirstDate()
        var startDate = GetPreviousMonthDate(today)
        if firstDate != nil && firstDate! < today {
            startDate = GetPreviousMonthDate(firstDate!)
        }
        let endDate = GetNextMonthDate(today)
        
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
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthTitle.text = formatter.string(from: range.start)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
}
