#if os(iOS)
import SwiftUI

#if canImport(FamilyControls)
import FamilyControls
#endif

struct SelectAppsOnboardingView: View {
    var progress: CGFloat
    var onComplete: () -> Void
    var onBack: () -> Void

    #if canImport(FamilyControls)
    @Environment(AppLockService.self) private var lockService
    @State private var isPickerPresented = false
    #endif

    var body: some View {
        #if canImport(FamilyControls)
        @Bindable var lockService = lockService
        #endif
        VStack(spacing: 0) {
            // Top bar (back + progress)
            HStack(spacing: 12) {
                Button {
                    onBack()
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

                SelectAppsProgressBar(progress: progress)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            // Subtitle above title
            Text("Let's set up FitRot!")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)

            // Title
            Text("Select your most distracting apps")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 8)

            // Caption
            Text("You can always change this later in the App's settings.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 8)

            Spacer()

            LottieView(animationName: "influencer")
                .frame(height: 280)
                .frame(maxWidth: 320)
                .padding(.horizontal, 40)

            Spacer()

            // Select Apps button
            Button {
                #if canImport(FamilyControls)
                isPickerPresented = true
                #endif
            } label: {
                Text("Select Apps")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.primary)
                    )
                    .foregroundStyle(Color(.systemBackground))
            }
            .padding(.horizontal, 20)

            // Skip button
            Button {
                onComplete()
            } label: {
                Text("Skip")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 12)
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
        #if canImport(FamilyControls)
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $lockService.selection)
        .onChange(of: lockService.selection) {
            lockService.commitSelection()
            onComplete()
        }
        #endif
    }
}

// MARK: - Progress Bar (inlined since the OnboardingView one is private)

private struct SelectAppsProgressBar: View {
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
#endif
