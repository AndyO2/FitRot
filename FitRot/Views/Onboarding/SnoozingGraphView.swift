#if os(iOS)
import SwiftUI

struct SnoozingGraphView: View {
    @State private var animationProgress: CGFloat = 0
    @State private var showLabels = false

    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Card
            VStack(alignment: .leading, spacing: 16) {
                Text("Time spent snoozing")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)

                GeometryReader { geo in
                    let size = geo.size
                    ZStack {
                        // Dashed reference lines
                        DashedLines()
                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                        // Filled region between curves (masked to reveal L→R)
                        FilledRegionBetweenCurves()
                            .fill(
                                LinearGradient(
                                    colors: [Color.red.opacity(0.15), Color(.systemGray5).opacity(0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .mask(
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .frame(width: size.width * animationProgress)
                                    Spacer(minLength: 0)
                                }
                            )

                        // Red curve — "Traditional alarm"
                        CurveLine(isTraditional: true)
                            .trim(from: 0, to: animationProgress)
                            .stroke(Color.red, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                        // Black curve — "With PushClock"
                        CurveLine(isTraditional: false)
                            .trim(from: 0, to: animationProgress)
                            .stroke(Color.primary, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                        // Open circle endpoints
                        if animationProgress > 0.99 {
                            // Traditional alarm endpoint (top-right area)
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .fill(Color(.systemBackground))
                                .frame(width: 8, height: 8)
                                .position(
                                    x: size.width,
                                    y: size.height * 0.08
                                )

                            // With PushClock endpoint (bottom-right area)
                            Circle()
                                .stroke(Color.primary, lineWidth: 2)
                                .fill(Color(.systemBackground))
                                .frame(width: 8, height: 8)
                                .position(
                                    x: size.width,
                                    y: size.height * 0.85
                                )
                        }

                        // Curve labels
                        Group {
                            Text("Traditional alarm")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.red)
                                .position(x: size.width * 0.72, y: size.height * 0.04)

                            Text("With PushClock")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.primary)
                                .position(x: size.width * 0.82, y: size.height * 0.93)
                        }
                        .opacity(showLabels ? 1 : 0)

                        // X-axis labels
                        Group {
                            Text("Day 1")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(.secondary)
                                .position(x: 20, y: size.height + 14)

                            Text("Day 30")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundStyle(.secondary)
                                .position(x: size.width - 22, y: size.height + 14)
                        }
                        .opacity(showLabels ? 1 : 0)
                    }
                }
                .frame(height: 160)
                .padding(.bottom, 24)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            // MARK: - Subtitle
            Text("84% of users report becoming a morning person after just 2 weeks.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .onAppear {
            animationProgress = 0
            showLabels = false
            withAnimation(.easeOut(duration: 1.5)) {
                animationProgress = 1
            }
            withAnimation(.easeInOut(duration: 0.4).delay(1.6)) {
                showLabels = true
            }
        }
    }
}

// MARK: - Shapes

private struct CurveLine: Shape {
    let isTraditional: Bool

    var animatableData: CGFloat { 0 }

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()
        let startY: CGFloat = 0.45

        if isTraditional {
            // Red: rises from middle to top (more snoozing)
            path.move(to: CGPoint(x: 0, y: h * startY))
            path.addCurve(
                to: CGPoint(x: w, y: h * 0.08),
                control1: CGPoint(x: w * 0.25, y: h * 0.55),
                control2: CGPoint(x: w * 0.6, y: h * 0.05)
            )
        } else {
            // Black: drops from middle to bottom (less snoozing)
            path.move(to: CGPoint(x: 0, y: h * startY))
            path.addCurve(
                to: CGPoint(x: w, y: h * 0.85),
                control1: CGPoint(x: w * 0.3, y: h * 0.65),
                control2: CGPoint(x: w * 0.55, y: h * 0.85)
            )
        }

        return path
    }
}

private struct FilledRegionBetweenCurves: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let startY: CGFloat = 0.45

        var path = Path()

        // Forward along traditional (red) curve
        path.move(to: CGPoint(x: 0, y: h * startY))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.08),
            control1: CGPoint(x: w * 0.25, y: h * 0.55),
            control2: CGPoint(x: w * 0.6, y: h * 0.05)
        )

        // Line down to PushClock endpoint
        path.addLine(to: CGPoint(x: w, y: h * 0.85))

        // Reverse along PushClock (black) curve
        path.addCurve(
            to: CGPoint(x: 0, y: h * startY),
            control1: CGPoint(x: w * 0.55, y: h * 0.85),
            control2: CGPoint(x: w * 0.3, y: h * 0.65)
        )

        path.closeSubpath()
        return path
    }
}

private struct DashedLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let lineCount = 4
        for i in 0..<lineCount {
            let y = rect.height * CGFloat(i) / CGFloat(lineCount)
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}

#Preview {
    SnoozingGraphView()
        .padding(.horizontal, 20)
        .frame(height: 350)
}
#endif
