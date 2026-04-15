//
//  StreakCalendarView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/15/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct StreakCalendarView: View {
    @Environment(StreakManager.self) private var streakManager
    @Binding var isPresented: Bool

    @State private var displayedMonth: Date = Calendar.current.startOfDay(for: Date())

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        return cal
    }

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    private var monthTitle: String {
        Self.monthFormatter.string(from: displayedMonth)
    }

    private let weekdaySymbols = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { dismiss() }

            card
                .padding(.horizontal, 24)
        }
    }

    private var card: some View {
        VStack(spacing: 20) {
            header
            monthNav
            weekdayRow
            dayGrid
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }

    private var header: some View {
        HStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("\(streakManager.displayStreak)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)
            }
            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(Color.black)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var monthNav: some View {
        HStack {
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primaryText)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(monthTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primaryText)

            Spacer()

            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.primaryText)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayGrid: some View {
        let cells = buildCells()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(cells.indices, id: \.self) { index in
                if let date = cells[index] {
                    dayCell(for: date)
                } else {
                    Color.clear.frame(height: 36)
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let hasWorkout = streakManager.hasWorkout(on: date)
        let isToday = calendar.isDateInToday(date)

        return Text("\(day)")
            .font(.system(size: 15, weight: hasWorkout ? .bold : .regular))
            .foregroundStyle(hasWorkout ? Color.white : Color.secondaryText)
            .frame(width: 36, height: 36)
            .background {
                if hasWorkout {
                    Circle().fill(Color.orange)
                } else if isToday {
                    Circle().stroke(Color.secondaryText.opacity(0.4), lineWidth: 1)
                }
            }
            .frame(maxWidth: .infinity)
    }

    private func shiftMonth(by delta: Int) {
        if let next = calendar.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = next
        }
    }

    private func buildCells() -> [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let dayRange = calendar.range(of: .day, in: .month, for: displayedMonth)
        else {
            return []
        }

        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        // Convert to Monday-first offset: Monday=0 ... Sunday=6
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in dayRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                cells.append(date)
            }
        }
        return cells
    }

    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isPresented = false
        }
    }
}

#endif
