#if os(iOS)
import Foundation

enum OnboardingStep: Identifiable {
    case question(id: String, text: String, subtitle: String? = nil, options: [String], allowMultiple: Bool = false)
    case info(id: String, text: String, subtitle: String? = nil, lottieAnimation: String? = nil, buttonText: String? = nil)
    case timePicker(id: String, text: String, subtitle: String? = nil)
    case graph(id: String, text: String, subtitle: String? = nil)
    case notification(id: String, text: String, subtitle: String? = nil)
    case commitment(id: String, text: String, subtitle: String? = nil)
    case setup(id: String, text: String, subtitle: String? = nil)
    case hoursSlider(id: String, text: String, subtitle: String? = nil)
    case videoDemo(id: String, text: String, subtitle: String? = nil, videoName: String, buttonText: String? = nil)

    var id: String {
        switch self {
        case .question(let id, _, _, _, _): id
        case .info(let id, _, _, _, _): id
        case .timePicker(let id, _, _): id
        case .graph(let id, _, _): id
        case .notification(let id, _, _): id
        case .commitment(let id, _, _): id
        case .setup(let id, _, _): id
        case .hoursSlider(let id, _, _): id
        case .videoDemo(let id, _, _, _, _): id
        }
    }

    var text: String {
        switch self {
        case .question(_, let text, _, _, _): text
        case .info(_, let text, _, _, _): text
        case .timePicker(_, let text, _): text
        case .graph(_, let text, _): text
        case .notification(_, let text, _): text
        case .commitment(_, let text, _): text
        case .setup(_, let text, _): text
        case .hoursSlider(_, let text, _): text
        case .videoDemo(_, let text, _, _, _): text
        }
    }

    var subtitle: String? {
        switch self {
        case .question(_, _, let subtitle, _, _): subtitle
        case .info(_, _, let subtitle, _, _): subtitle
        case .timePicker(_, _, let subtitle): subtitle
        case .graph(_, _, let subtitle): subtitle
        case .notification(_, _, let subtitle): subtitle
        case .commitment(_, _, let subtitle): subtitle
        case .setup(_, _, let subtitle): subtitle
        case .hoursSlider(_, _, let subtitle): subtitle
        case .videoDemo(_, _, let subtitle, _, _): subtitle
        }
    }

    var options: [String] {
        switch self {
        case .question(_, _, _, let options, _): options
        case .info, .timePicker, .graph, .notification, .commitment, .setup, .hoursSlider, .videoDemo: []
        }
    }

    var allowMultiple: Bool {
        if case .question(_, _, _, _, let allowMultiple) = self { return allowMultiple }
        return false
    }

    var lottieAnimation: String? {
        if case .info(_, _, _, let anim, _) = self { return anim }
        return nil
    }

    var buttonText: String? {
        if case .info(_, _, _, _, let text) = self { return text }
        if case .videoDemo(_, _, _, _, let text) = self { return text }
        return nil
    }

    var videoName: String? {
        if case .videoDemo(_, _, _, let name, _) = self { return name }
        return nil
    }

    var isVideoDemo: Bool {
        if case .videoDemo = self { return true }
        return false
    }

    var isInfo: Bool {
        if case .info = self { return true }
        return false
    }

    var isTimePicker: Bool {
        if case .timePicker = self { return true }
        return false
    }

    var isGraph: Bool {
        if case .graph = self { return true }
        return false
    }

    var isNotification: Bool {
        if case .notification = self { return true }
        return false
    }

    var isCommitment: Bool {
        if case .commitment = self { return true }
        return false
    }

    var isSetup: Bool {
        if case .setup = self { return true }
        return false
    }

    var isHoursSlider: Bool {
        if case .hoursSlider = self { return true }
        return false
    }

    var isQuestion: Bool {
        if case .question = self { return true }
        return false
    }

    var stepType: String {
        switch self {
        case .question: "question"
        case .info: "info"
        case .timePicker: "timePicker"
        case .graph: "graph"
        case .notification: "notification"
        case .commitment: "commitment"
        case .setup: "setup"
        case .hoursSlider: "hoursSlider"
        case .videoDemo: "videoDemo"
        }
    }
}

// MARK: - Edit steps here

enum OnboardingData {
    static var steps: [OnboardingStep] {[
        .question(
            id: "goal",
            text: String(localized: "What goals do you want to achieve using FitRot?"),
            subtitle: String(localized: "Select multiple options"),
            options: [
                String(localized: "Reduce Screen Time 📵"),
                String(localized: "Quit late-night / early-morning scrolling ❌"),
                String(localized: "Build consistency & self-control 🎧"),
                String(localized: "Better focus for study 📖"),
                String(localized: "Improved productivity at work 📈"),
                String(localized: "Boost energy & mood 😁"),
                String(localized: "Lose weight 🔥"),
                String(localized: "Be more present 🧘"),
                String(localized: "Less social isolation 🧍"),
                String(localized: "Join challenges & compete 🏃"),
                String(localized: "Build muscle 💪")
            ],
            allowMultiple: true,
        ),
        .hoursSlider(
            id: "phone_usage",
            text: String(localized: "How much time do you spend on your phone every day?"),
            subtitle: String(localized: "This helps us understand your phone usage a bit more.")
        ),
        .hoursSlider(
            id: "target_cut_down",
            text: String(localized: "How many hours of screen time do you want to cut down to?"),
            subtitle: String(localized: "This will be your daily goal — we'll help you stick to it.")
        ),
        .info(
            id: "goals_social_proof",
            text: String(localized: "Over 300,000 People\nstarted with the same goals!"),
            buttonText: String(localized: "I'm next")
        ),
        .question(
            id: "apps_taking_most_time",
            text: String(localized: "Which apps are taking most of your time?"),
            subtitle: String(localized: "Select multiple options"),
            options: [
                "TikTok",
                "Instagram",
                "YouTube",
                "Mobile Games", 
                "Twitter (X)",
                "Reddit",
                "Discord",
                "Online Shopping",
                "Twitch",
                "Netflix (or other streaming)",
                "Snapchat"
            ],
            allowMultiple: true
        ),
        .question(
            id: "what_makes_it_hard_to_quit",
            text: String(localized: "What usually makes it hard to quit?"),
            subtitle: String(localized: "Select multiple options"),
            options: [
                String(localized: "Fear of Missing Out (FOMO)"),
                String(localized: "Addictive App design (infinite scroll, algorithm, notifications)"),
                String(localized: "It's just automatic, no reason"),
                String(localized: "Fills boring moments"),
                String(localized: "Procrastinating harder tasks"),
                String(localized: "Coping with stress / low mood"),
                String(localized: "Wanting Community"),
                String(localized: "Comparing myself to others"),
                String(localized: "My job requires me to be online"),
                String(localized: "It's too easy to reach"),
            ],
            allowMultiple: true,
        ),
        .question(
            id: "how_using_apps_make_you_feel",
            text: String(localized: "How does using these apps for too long make you feel?"),
            subtitle: String(localized: "Select multiple options"),
            options: [
                String(localized: "Irritable 😡"),
                String(localized: "Not Present 🙃"),
                String(localized: "Mentally Drained 😪"),
                String(localized: "Regretful or Guilty 😩"),
                String(localized: "Empty or Hollow 😣"),
                String(localized: "Powerless 😔"),
                String(localized: "Anxious 😰"),
                String(localized: "Insecure 😕"),
                String(localized: "Overstimulated 😣"),
            ],
            allowMultiple: true,
        ),
        .info(
            id: "current_state",
            text: String(localized: "Current State")
        ),
        .question(
            id: "age",
            text: String(localized: "How old are you?"),
            options: [
                String(localized: "Under 18"),
                String(localized: "18-24"),
                String(localized: "25-29"),
                String(localized: "30-40"),
                String(localized: "40 and over")
            ]
        ),
        .info(
            id: "phone_dependence_analysis",
            text: String(localized: "It doesn't look good so far…")
        ),
        .info(
            id: "phone_projection",
            text: String(localized: "At your current rate…")
        ),
        .info(
            id: "good_news_projection",
            text: String(localized: "The good news is that FitRot can help you get back…")
        ),
        .question(
            id: "what_have_you_already_tried",
            text: String(localized: "What have you already tried?"),
            subtitle: String(localized: "Select multiple options"),
            options: [
                String(localized: "Nothing yet 🤷‍♂️"),
                String(localized: "Screen time limiters 📵"),
                String(localized: "Uninstalling addicting apps ❌"),
                String(localized: "Using Browser only version 🖥️"),
                String(localized: "Digital Detox 📵"),
                String(localized: "Grayscale Mode 🌑"),
                String(localized: "Working on Mindset 🧠"),
                String(localized: "Keeping phone out of reach 🤳"),
                String(localized: "Buying a Dumb Phone ☎️"),
                String(localized: "Morning/Night Routine 🧘"),
                String(localized: "NFC Tag to block apps 🫷"),
                String(localized: "Minimalist Launcher 📱"),
            ],
            allowMultiple: true
        ),
        .info(
            id: "research_breakdown",
            text: String(localized: "Big respect for tackling something tough."),
            subtitle: String(localized: "We did the research, here's the breakdown:"),
            buttonText: String(localized: "See how FitRot works")
        ),
        .info(
            id: "quitting_is_hard",
            text: String(localized: "We know that Quitting is hard.")
        ),
//        TODO: In FitRot, you save up Screen Time by exercising (animated)
//        TODO: Scroll, you can use your saved up Screen Time (animated)
        .timePicker(
            id: "exercise_time",
            text: String(localized: "What is the best time for you to Exercise?"),
            subtitle: String(localized: "Reminders make it 65% more likely to stick to FitRot after a week.")
        ),
//        TODO: Try out favorite exercise from below! (pushups + squats) selection only
        //        .info(
        //            id: "try_exercise",
        //            text: String(localized: "Try out your favourite Exercise from below!"),
        //            subtitle: String(localized: "You can also skip this"),
        //            buttonText: String(localized: "Try Later")
        //        ),
        .videoDemo(
            id: "setup",
            text: String(localized: "Setup"),
            subtitle: String(localized: "Place your phone on the floor facing you in a well-lit area."),
            videoName: "setup"
        ),
        .videoDemo(
            id: "pushup",
            text: String(localized: "Push-ups"),
            subtitle: String(localized: "Put your entire body in frame and exercise like in the video!"),
            videoName: "pushup"
        ),
        .info(id: "tips_for_better_detection", text: String(localized: "Tips for better detection")),
//        TODO: live demonstration with camera (CTA: try later)
        .question(
            id: "how_often_you_currently_exercise",
            text: String(localized: "How often do you currently exercise?"),
            options: [
                String(localized: "Never"),
                String(localized: "1-3 timer per week"),
                String(localized: "3-5 times per week"),
                String(localized: "Every day"),
            ]
        ),
        .info(id: "finish_setup_typing", text: "Let's finish setting up FitRot to help you succeed.", buttonText: "Set Up"),
        .info(id: "screen_time_permission", text: "Connect FitRot to Screen Time, Securely.", subtitle: "To analyze your Screen Time on this iPhone, FitRot will need your permission"),
        .info(id: "select_apps", text: "Select your most distracting apps", subtitle: "You can always change this later in the App's settings.", buttonText: "Continue"),
        .notification(id: "notifications", text: "Reach your goals with notifications", subtitle: "We use this to allow you to unblock your apps when you want to use them."),
        .info(id: "rating", text: String(localized: "12,380 Screens Silenced")),
        .info(id: "referral_code", text: String(localized: "Have a referral code?"), subtitle: String(localized: "Enter a friend's code to unlock a reward. You can skip this step if you don't have one.")),
//        TODO: Join FitRot (continue with apple/email/skip) maybe just apple + google
        .setup(id: "setup_progress", text: String(localized: "We're setting everything\nup for you")),
//        TODO: Your journey to self improvement starts now (chart)
    ]}
}
#endif
