//
//  ScreenTimeDashboardData.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/9/26.
//

import Foundation

struct ScreenTimeDayUsage: Identifiable {
    let id = UUID()
    let date: Date
    let totalDuration: TimeInterval
    let categories: [ScreenTimeCategoryUsage]

    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct ScreenTimeCategoryUsage: Identifiable {
    let id = UUID()
    let name: String
    let duration: TimeInterval
    let colorName: String
}

struct ScreenTimeDashboardData {
    let days: [ScreenTimeDayUsage]
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let changePercentage: Double
    let topCategories: [ScreenTimeCategoryUsage]
    let lastUpdated: Date

    static var placeholder: ScreenTimeDashboardData {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        let categoryTemplates: [(String, Double, String)] = [
            ("Social", 0.53, "blue"),
            ("Entertainment", 0.27, "purple"),
            ("Productivity", 0.13, "green"),
            ("Finance", 0.07, "cyan"),
        ]

        let dailyTotals: [TimeInterval] = [
            9.2 * 3600, 7.8 * 3600, 8.5 * 3600, 10.1 * 3600,
            7.3 * 3600, 8.9 * 3600, 7.5 * 3600,
        ]

        let days: [ScreenTimeDayUsage] = (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -(6 - dayOffset), to: today)!
            let total = dailyTotals[dayOffset]
            let categories = categoryTemplates.map { name, fraction, colorName in
                let jitter = Double.random(in: 0.85...1.15)
                return ScreenTimeCategoryUsage(
                    name: name,
                    duration: total * fraction * jitter,
                    colorName: colorName
                )
            }
            return ScreenTimeDayUsage(date: date, totalDuration: total, categories: categories)
        }

        let total = days.reduce(0) { $0 + $1.totalDuration }
        let average = total / Double(days.count)

        let aggregated = categoryTemplates.map { name, _, colorName in
            let duration = days.reduce(0.0) { sum, day in
                sum + (day.categories.first { $0.name == name }?.duration ?? 0)
            }
            return ScreenTimeCategoryUsage(name: name, duration: duration, colorName: colorName)
        }.sorted { $0.duration > $1.duration }

        return ScreenTimeDashboardData(
            days: days,
            totalDuration: total,
            averageDuration: average,
            changePercentage: -12.56,
            topCategories: aggregated,
            lastUpdated: .now
        )
    }
}
