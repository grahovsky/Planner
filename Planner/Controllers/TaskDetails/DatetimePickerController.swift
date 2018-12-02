//
//  DatetimePickerController.swift
//  Planner
//
//  Created by Konstantin on 01/12/2018.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import GCCalendar // обязательно надо импортировать, чтобы работать с календарем

class DatetimePickerController: UIViewController, GCCalendarViewDelegate {
    
    
    var delegate: ActionResultDelegate!
    var initDeadLine: Date!
    var selectedDate: Date!
    
    var dateFormatter: DateFormatter!
   
    @IBOutlet weak var calendarView: GCCalendarView!
    @IBOutlet weak var labelMonthName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter = createDateFormatter()
        
        calendarView.delegate = self
        calendarView.displayMode = .month
        
        if let date = initDeadLine {
            calendarView.select(date: date)
        }
        
    }

    @IBAction func tapCancel(_ sender: UIButton) {
    
        closeController()
        
    }
    
    @IBAction func tapToday(_ sender: UIButton) {
    
        calendarView.today()
        
    }
    
    @IBAction func tapSave(_ sender: UIButton) {
    
        closeController()
        delegate.done(source: self, data: selectedDate)
        
    }
    
    
    //MARK: GCCalendarViewDelegate
    
    func calendarView(_ calendarView: GCCalendarView, didSelectDate date: Date, inCalendar calendar: Calendar) {
        
        dateFormatter.dateFormat = "LLLL yyyy"
        dateFormatter.calendar = calendar
        
        labelMonthName.text = dateFormatter.string(from: date).capitalized
        
        selectedDate = date

    }
    
}
