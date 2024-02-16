//
//  DateUtil.swift
//  GeSwiftTools
//
//  Created by mayong on 2023/2/16.
//

import Foundation

public extension Date {
    enum DateWeek: Int {
        case saturday = 7
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
    }
    
    /// 时区
    static func dateWithTimeIntervalSinceStartDate(_ timeInterval: TimeInterval, date: Date) -> Date {
        let zone = NSTimeZone.system
        let interval = zone.secondsFromGMT()
        return date.addingTimeInterval(Double(interval))
    }

    /// weak day
    var week: DateWeek {
        return DateWeek(rawValue: components(dateSets: [.weekday]).weekday!)!
    }
        
    /// month
    var month: Int {
        return components(dateSets: [.month]).month!
    }
        
    /// day
    var day: Int {
        return components(dateSets: [.day]).day!
    }
        
    /// year
    var year: Int {
        return components(dateSets: [.year]).year!
    }
        
    /// ear
    var era: Int {
        return components(dateSets: [.era]).era!
    }
        
    /// hour
    var hour: Int {
        return components(dateSets: [.hour]).hour!
    }
        
    /// minute
    var minute: Int {
        return components(dateSets: [.minute]).minute!
    }
        
    /// second
    var second: Int {
        return components(dateSets: [.second]).second!
    }
        
    /// 这个月的第几周
    var weekdayOrdinal: Int {
        return components(dateSets: [.weekdayOrdinal]).weekdayOrdinal!
    }
        
    /// 季度
    var quarter: Int {
        return components(dateSets: [.quarter]).quarter!
    }
        
    /// 这个月的第几个星期
    var weekOfMonth: Int {
        return components(dateSets: [.weekOfMonth]).weekOfMonth!
    }
        
    /// 该年的第几个星期
    var weekOfYear: Int {
        return components(dateSets: [.weekOfYear]).weekOfYear!
    }
        
    /// 判断该月是否为润月
    var leapMonth: Bool {
        return components(dateSets: [.yearForWeekOfYear]).isLeapMonth!
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    var isInWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }

    func isYearEqual(_ date: Date) -> Bool {
        year == date.year
    }

    func isMonthEqual(_ date: Date) -> Bool {
        let selfYearAndMonth = components(dateSets: [.year, .month])
        let dateYearAndMonth = date.components(dateSets: [.year, .month])
        return selfYearAndMonth.year == dateYearAndMonth.year && selfYearAndMonth.month == dateYearAndMonth.month
    }

    func isWeakEqual(_ date: Date) -> Bool {
        let selfYearAndWeak = components(dateSets: [.year, .weekOfYear])
        let dateYearAndWeak = date.components(dateSets: [.year, .weekOfYear])
        return selfYearAndWeak.year == dateYearAndWeak.year && selfYearAndWeak.weekOfYear == dateYearAndWeak.weekOfYear
    }

    func isDayEqual(_ date: Date) -> Bool {
        let selfYearAndDay = components(dateSets: [.year, .month, .day])
        let dateYearAndDay = date.components(dateSets: [.year, .month, .day])
        return selfYearAndDay.year == dateYearAndDay.year &&
            selfYearAndDay.month == dateYearAndDay.month &&
            selfYearAndDay.day == dateYearAndDay.day
    }
        
    /// get components from format component
    ///
    /// - Parameter dateSets: components
    /// - Returns: DateComponents
    func components(_ calendar: Calendar = Calendar.current, dateSets: Set<Calendar.Component>) -> DateComponents {
        return calendar.dateComponents(dateSets, from: self)
    }
        
    /// date to string
    ///
    /// - Parameter format: format
    /// - Returns: time string
    func serializeToString(using format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
