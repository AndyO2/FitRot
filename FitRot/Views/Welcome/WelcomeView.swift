#if os(iOS)
import SwiftUI
import SuperwallKit

struct WelcomeView: View {
    var onBuildPlan: () -> Void = {}
    var onSkip: () -> Void = {}
    @State private var showRestartAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                HStack(spacing: 8) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("FitRot")
                        .font(.system(size: 22, weight: .bold))
                }

                /*
                HStack {
                    Spacer()
                    Menu {
                        Button {
                            languageBinding.wrappedValue = "en"
                        } label: {
                            Label("🇺🇸 English", systemImage: languageBinding.wrappedValue == "en" ? "checkmark" : "")
                        }
                        Button {
                            languageBinding.wrappedValue = "es"
                        } label: {
                            Label("🇪🇸 Español", systemImage: languageBinding.wrappedValue == "es" ? "checkmark" : "")
                        }
                        Button {
                            languageBinding.wrappedValue = "fr"
                        } label: {
                            Label("🇫🇷 Français", systemImage: languageBinding.wrappedValue == "fr" ? "checkmark" : "")
                        }
                        Button {
                            languageBinding.wrappedValue = "de"
                        } label: {
                            Label("🇩🇪 Deutsch", systemImage: languageBinding.wrappedValue == "de" ? "checkmark" : "")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(currentFlag)
                                .font(.system(size: 20))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                */
            }
            .frame(maxWidth: .infinity)

            Spacer()
                .frame(height: 32)

            LottieView(animationName: "Scrolling")
                .frame(height: 160)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            Spacer()
                .frame(height: 36)

            Text("Replace Doomscrolling with Exercise")
                .font(.system(size: 40, weight: .bold))
                .lineSpacing(2)

            Spacer()
                .frame(height: 16)

            HStack(spacing: 0) {
                StarRatingBadge()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: 16) {
                Button(action: onBuildPlan) {
                    Text("Get Started ➡️")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color(.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.primary, in: Capsule())
                }

                #if DEBUG
                Button(action: onSkip) {
                    Text("Go To App (DEV)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.red)
                }
                Button {
                    Superwall.shared.register(placement: "campaign_trigger")
                } label: {
                    Text("Show Paywall (DEV)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.red)
                }
                #endif
            }
        }
        .padding(.horizontal, 24)
        .alert("Restart Required", isPresented: $showRestartAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please restart the app for the language change to take effect.")
        }
    }

    private var languageBinding: Binding<String> {
        Binding<String>(
            get: {
                let languages = UserDefaults.standard.stringArray(forKey: "AppleLanguages") ?? []
                let first = languages.first ?? "en"
                if first.hasPrefix("es") { return "es" }
                if first.hasPrefix("fr") { return "fr" }
                if first.hasPrefix("de") { return "de" }
                return "en"
            },
            set: { newValue in
                UserDefaults.standard.set([newValue], forKey: "AppleLanguages")
                showRestartAlert = true
            }
        )
    }

    private var currentFlag: String {
        switch languageBinding.wrappedValue {
        case "es": return "🇪🇸"
        case "fr": return "🇫🇷"
        case "de": return "🇩🇪"
        default: return "🇺🇸"
        }
    }
}

private struct StarRatingBadge: View {
    var body: some View {
        HStack(spacing: -4) {
            // Left laurel
            Image(systemName: "laurel.leading")
                .font(.system(size: 60))
                .foregroundStyle(.secondary.opacity(0.6))

            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.72, blue: 0.35),
                                         Color(red: 0.75, green: 0.6, blue: 0.25)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(red: 0.75, green: 0.6, blue: 0.25).opacity(0.3), radius: 2, y: 1)
                }
            }

            // Right laurel
            Image(systemName: "laurel.trailing")
                .font(.system(size: 60))
                .foregroundStyle(.secondary.opacity(0.6))
        }
    }
}
#endif

#Preview {
    WelcomeView()
}
