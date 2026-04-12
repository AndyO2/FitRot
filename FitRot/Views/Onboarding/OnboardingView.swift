#if os(iOS)
import SwiftUI
import StoreKit
import SuperwallKit

struct OnboardingView: View {
    var onComplete: () -> Void
    var onBack: () -> Void = {}

    private let steps = OnboardingData.steps

    @State private var currentIndex = 0
    @State private var answers: [String: [String]] = [:]
    @State private var selectedOptions: Set<String> = []
    @State private var selectedTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!
    @State private var hasSignature = false
    @AppStorage("dailyPhoneHours") private var dailyPhoneHours: Int = 4
    @AppStorage("targetPhoneHours") private var targetPhoneHours: Int = 2
    @AppStorage("goalWakeUpHour") private var goalWakeUpHour: Int = 7
    @AppStorage("goalWakeUpMinute") private var goalWakeUpMinute: Int = 0
    @AppStorage("referralCode") private var referralCode: String = ""
    @AppStorage("exerciseReminderHour") private var exerciseReminderHour: Int = 14
    @AppStorage("exerciseReminderMinute") private var exerciseReminderMinute: Int = 35
    @State private var exerciseTime = Calendar.current.date(from: DateComponents(hour: 14, minute: 35))!

    private var currentStep: OnboardingStep {
        steps[currentIndex]
    }

    private var progress: CGFloat {
        CGFloat(currentIndex + 1) / CGFloat(steps.count)
    }

    private var canContinue: Bool {
        currentStep.isInfo || currentStep.isTimePicker || currentStep.isGraph || currentStep.isHoursSlider || currentStep.isVideoDemo || (currentStep.isCommitment && hasSignature) || !selectedOptions.isEmpty
    }

    private var displayText: String {
        var text = currentStep.text
        if text.contains("[goal_time]") {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let date = Calendar.current.date(from: DateComponents(hour: goalWakeUpHour, minute: goalWakeUpMinute)) ?? Date()
            text = text.replacingOccurrences(of: "[goal_time]", with: formatter.string(from: date))
        }
        return text
    }

    private var displaySubtitle: String? {
        guard var subtitle = currentStep.subtitle else { return nil }
        if subtitle.contains("[goal_time]") {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let date = Calendar.current.date(from: DateComponents(hour: goalWakeUpHour, minute: goalWakeUpMinute)) ?? Date()
            subtitle = subtitle.replacingOccurrences(of: "[goal_time]", with: formatter.string(from: date))
        }
        return subtitle
    }

    private func trackStepViewed() {
        AnalyticsService.shared.track("onboarding_step_viewed", properties: [
            "step_id": currentStep.id,
            "step_index": currentIndex,
            "step_type": currentStep.stepType,
            "step_total": steps.count
        ])
    }

    var body: some View {
        Group {
        if currentStep.id == "finish_setup_typing" {
            FinishSetupView(
                onSetUp: { advance() },
                onBack: { goBack() }
            )
        } else if currentStep.id == "screen_time_permission" {
            ScreenTimePermissionView(
                onComplete: { advance() },
                onBack: { goBack() }
            )
        } else if currentStep.id == "select_apps" {
            SelectAppsOnboardingView(
                progress: progress,
                onComplete: { advance() },
                onBack: { goBack() }
            )
        } else if currentStep.isSetup {
            SetupProgressView {
                advance()
            }
        } else if currentStep.id == "exercise_time" {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button {
                        goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                    }

                    ProgressBar(progress: progress)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ExerciseTimePickerView(
                    selectedTime: $exerciseTime,
                    onSetRoutine: {
                        let c = Calendar.current.dateComponents([.hour, .minute], from: exerciseTime)
                        exerciseReminderHour = c.hour ?? 14
                        exerciseReminderMinute = c.minute ?? 0
                        advance()
                    },
                    onSkip: { advance() }
                )
            }
            .background(Color(.systemGroupedBackground))
        } else if currentStep.id == "notifications" {
            NotificationOnboardingView(
                progress: progress,
                title: displayText,
                subtitle: displaySubtitle,
                onComplete: { advance() },
                onBack: { goBack() }
            )
        } else if currentStep.isVideoDemo {
            VStack(spacing: 0) {
                // Top bar (back + progress)
                HStack(spacing: 12) {
                    Button {
                        goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                            )
                    }

                    ProgressBar(progress: progress)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                VideoDemoView(
                    videoName: currentStep.videoName ?? "",
                    title: displayText,
                    subtitle: displaySubtitle,
                    buttonText: currentStep.buttonText ?? "Next",
                    onNext: { advance() }
                )
            }
            .background(Color(.systemGroupedBackground))
        } else {
        VStack(spacing: 0) {
            // MARK: - Top bar
            HStack(spacing: 12) {
                Button {
                    goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }

                ProgressBar(progress: progress)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // MARK: - Title
                if currentStep.id != "trust_privacy"
                    && currentStep.id != "goals_social_proof"
                    && currentStep.id != "phone_dependence_analysis"
                    && currentStep.id != "phone_projection"
                    && currentStep.id != "good_news_projection"
                    && currentStep.id != "current_state"
                    && currentStep.id != "quitting_is_hard"
                    && currentStep.id != "try_exercise"
                    && currentStep.lottieAnimation == nil {
                    Text(displayText)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(currentStep.id == "rating" ? .center : .leading)
                        .frame(maxWidth: .infinity, alignment: currentStep.id == "rating" ? .center : .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    if let subtitle = displaySubtitle {
                        if currentStep.isCommitment, let attributed = try? AttributedString(markdown: subtitle) {
                            Text(attributed)
                                .font(.system(size: 17))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        } else {
                            Text(subtitle)
                                .font(.system(size: 17))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }
                    }
                }

                if !currentStep.isQuestion {
                    Spacer()
                }

                // MARK: - Options / Time Picker / Graph / Info
                if currentStep.isGraph {
                    SnoozingGraphView()
                        .padding(.horizontal, 20)

                    Spacer()
                } else if currentStep.isTimePicker {
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding(.horizontal, 20)

                    Spacer()
                } else if currentStep.isHoursSlider {
                    hoursSliderContent(for: currentStep.id)

                    Spacer()
                } else if currentStep.isCommitment {
                    SignCommitmentView(hasSignature: $hasSignature)

                    Spacer()
                } else if currentStep.isInfo {
                    infoContent(for: currentStep.id)

                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(Array(currentStep.options.enumerated()), id: \.element) { index, option in
                                OptionButton(
                                    title: option,
                                    number: index + 1,
                                    isSelected: selectedOptions.contains(option)
                                ) {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    if currentStep.allowMultiple {
                                        if selectedOptions.contains(option) {
                                            selectedOptions.remove(option)
                                        } else {
                                            selectedOptions.insert(option)
                                        }
                                    } else {
                                        selectedOptions = [option]
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                    }
                    .frame(maxHeight: .infinity)
                }

                // MARK: - Continue button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    advance()
                } label: {
                    Text(currentStep.buttonText ?? "Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(currentStep.id == "try_exercise" ? Color.clear : (canContinue ? Color.primary : Color(.systemGray4)))
                        )
                        .foregroundStyle(currentStep.id == "try_exercise" ? Color.primary : (canContinue ? Color(.systemBackground) : Color(.systemGray)))
                        .overlay(
                            currentStep.id == "try_exercise"
                                ? RoundedRectangle(cornerRadius: 32).stroke(Color.primary, lineWidth: 2)
                                : nil
                        )
                }
                .disabled(!canContinue)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
        }
        }
        .onAppear {
            AnalyticsService.shared.timeEvent("onboarding_completed")
            trackStepViewed()
        }
        .onChange(of: currentIndex) {
            trackStepViewed()
        }
    }

    // MARK: - Info Content

    @ViewBuilder
    private func infoContent(for id: String) -> some View {
        switch id {
        case "trust_privacy":
            TrustPrivacyView()
        case "rating":
            RatingView()
        case "phone_dependence_analysis":
            PhoneDependenceAnalysisView()
        case "phone_projection":
            PhoneProjectionView()
                .padding(.horizontal, 20)
        case "good_news_projection":
            PhoneProjectionView(configuration: .goodNews)
                .padding(.horizontal, 20)
        case "referral_code":
            ReferralCodeView()
                .padding(.horizontal, 20)
        case "goals_social_proof":
            GoalsSocialProofView(selectedGoals: answers["goal"] ?? [])
                .padding(.horizontal, 20)
        case "current_state":
            CurrentStateView(
                topApps: answers["apps_taking_most_time"] ?? [],
                topFeelings: answers["how_using_apps_make_you_feel"] ?? []
            )
            .padding(.horizontal, 20)
        case "tips_for_better_detection":
            TipsForBetterDetectionView()
        case "quitting_is_hard":
            QuittingIsHardView()
        case "research_breakdown":
            ResearchBreakdownView(
                triedMethods: answers["what_have_you_already_tried"] ?? []
            )
            .padding(.horizontal, 20)
        case "try_exercise":
            TryExerciseView(onExerciseCompleted: { advance() })
        default:
            if let animationName = currentStep.lottieAnimation {
                LottieInfoContentView(
                    animationName: animationName,
                    title: displayText,
                    subtitle: displaySubtitle
                )
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func hoursSliderContent(for id: String) -> some View {
        switch id {
        case "phone_usage":
            HoursSliderView(
                value: $dailyPhoneHours,
                label: "HOURS PER DAY",
                leadingCaption: "None",
                trailingCaption: "All day",
                infoText: "Most people underestimate their daily phone time. Move the slider to your best guess.",
                accentColor: .red
            )
        case "target_cut_down":
            HoursSliderView(
                value: $targetPhoneHours,
                label: "HOURS PER DAY",
                leadingCaption: "None",
                trailingCaption: "All day",
                infoText: "Pick a target that feels achievable. Small wins build momentum.",
                accentColor: .blue
            )
        default:
            EmptyView()
        }
    }

    // MARK: - Navigation

    private func goBack() {
        guard currentIndex > 0 else {
            onBack()
            return
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentIndex -= 1
            selectedOptions = Set(answers[steps[currentIndex].id] ?? [])
            if steps[currentIndex].id == "exercise_time" {
                exerciseTime = Calendar.current.date(from: DateComponents(hour: exerciseReminderHour, minute: exerciseReminderMinute)) ?? exerciseTime
            } else if steps[currentIndex].isTimePicker {
                selectedTime = Calendar.current.date(from: DateComponents(hour: goalWakeUpHour, minute: goalWakeUpMinute)) ?? selectedTime
            } else if steps[currentIndex].isCommitment {
                hasSignature = false
            }
        }
    }

    private func advance() {
        if currentStep.id == "exercise_time" {
            // exercise_time saves are handled by ExerciseTimePickerView's onSetRoutine callback
        } else if currentStep.isTimePicker {
            let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
            goalWakeUpHour = components.hour ?? 7
            goalWakeUpMinute = components.minute ?? 0
        } else if currentStep.isHoursSlider {
            // value is already persisted via @AppStorage
        } else if !selectedOptions.isEmpty {
            let selections = Array(selectedOptions)
            answers[currentStep.id] = selections
            AnalyticsService.shared.track("onboarding_question_answered", properties: [
                "step_id": currentStep.id,
                "step_index": currentIndex,
                "answer": selections.joined(separator: ", ")
            ])
        }

        if currentIndex < steps.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex += 1
                selectedOptions = Set(answers[steps[currentIndex].id] ?? [])
            }
        } else {
            AnalyticsService.shared.track("onboarding_completed")
            let code = referralCode.uppercased()
            if code != "FOUNDER" && code != "CREATOR1" {
                Superwall.shared.register(placement: "campaign_trigger")
            }
            onComplete()
        }
    }
}

// MARK: - Components

private struct ProgressBar: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 4)

                Capsule()
                    .fill(Color.primary)
                    .frame(width: max(geo.size.width * progress, 4), height: 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}

private struct OptionButton: View {
    let title: String
    let number: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.green : Color(.systemGray5))
                        .frame(width: 44, height: 44)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(number)")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(.systemGray))
                    }
                }

                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color(.label))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
    }
}

private struct LottieInfoContentView: View {
    let animationName: String
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: 16) {
            LottieView(animationName: animationName)
                .frame(height: 200)

            Text(title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
}
#endif

#if os(iOS)
#Preview {
    OnboardingView(onComplete: {})
}
#endif
