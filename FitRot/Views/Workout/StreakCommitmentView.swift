//
//  StreakCommitmentView.swift
//  FitRot
//

import SwiftUI
import Lottie

#if canImport(FamilyControls)

struct StreakCommitmentView: View {
    @Environment(StreakManager.self) private var streakManager

    var onCommit: () -> Void = {}

    @State private var todayFilled = false

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1 // Sunday
        return cal
    }

    private let weekdayLabels = ["SU", "M", "TU", "W", "TH", "F", "S"]

    private var weekDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today) // 1 = Sunday
        guard let sunday = calendar.date(byAdding: .day, value: -(weekday - 1), to: today) else {
            return []
        }
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: sunday)
        }
    }

    private var streakValue: Int {
        max(streakManager.displayStreak, 1)
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Text("Can you exercise everyday?")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 40)

                Spacer(minLength: 20)

                flame
                    .frame(width: 220, height: 220)

                streakNumber

                Text("day streak")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.top, 4)

                Spacer(minLength: 24)

                daysRow
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)

                commitButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            todayFilled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
                    todayFilled = true
                }
            }
        }
    }

    private var background: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(red: 0.07, green: 0.10, blue: 0.22),
                    Color.black
                ],
                center: .top,
                startRadius: 20,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var flame: some View {
        #if os(iOS)
        LottieView(animationName: "flame", loopMode: .loop)
        #else
        Image(systemName: "flame.fill")
            .font(.system(size: 160))
            .foregroundStyle(Color.orange)
        #endif
    }

    private var streakNumber: some View {
        Text("\(streakValue)")
            .font(.system(size: 140, weight: .heavy, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.72, blue: 0.20),
                        Color(red: 1.0, green: 0.48, blue: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .padding(.top, -8)
    }

    private var daysRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekDays.enumerated()), id: \.offset) { index, date in
                dayCircle(for: date, weekdayLabel: weekdayLabels[index])
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCircle(for date: Date, weekdayLabel: String) -> some View {
        let day = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let hasWorkout = streakManager.hasWorkout(on: date)
        let showFill = hasWorkout && (!isToday || todayFilled)
        return VStack(spacing: 8) {
            Text("\(day)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(showFill ? Color.orange : Color.white.opacity(0.5))

            ZStack {
                Circle()
                    .stroke(Color.orange.opacity(0.55), lineWidth: 1.5)
                    .frame(width: 38, height: 38)
                    .opacity(showFill ? 0 : 1)

                Circle()
                    .fill(Color.orange)
                    .frame(width: 38, height: 38)
                    .shadow(color: Color.orange.opacity(0.55), radius: 10, y: 2)
                    .scaleEffect(showFill ? 1 : 0.3)
                    .opacity(showFill ? 1 : 0)

                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.white)
                    .scaleEffect(showFill ? 1 : 0.1)
                    .opacity(showFill ? 1 : 0)
            }

            Text(weekdayLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.45))
                .padding(.top, 2)
        }
    }

    private var commitButton: some View {
        Button {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            onCommit()
        } label: {
            Text("I'm committed")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Dark") {
    StreakCommitmentView()
        .environment(StreakManager())
        .preferredColorScheme(.dark)
}

#Preview("Light") {
    StreakCommitmentView()
        .environment(StreakManager())
        .preferredColorScheme(.light)
}

#endif
