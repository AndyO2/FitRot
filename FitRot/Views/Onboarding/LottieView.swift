#if os(iOS)
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit

    final class Coordinator {
        var loadedName: String?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: animationName)
        view.loopMode = loopMode
        view.contentMode = contentMode
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        context.coordinator.loadedName = animationName
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if uiView.loopMode != loopMode {
            uiView.loopMode = loopMode
        }
        if uiView.contentMode != contentMode {
            uiView.contentMode = contentMode
        }
        // Only reload and restart playback when the animation name actually
        // changes. Reassigning on every SwiftUI update causes flicker.
        if context.coordinator.loadedName != animationName {
            uiView.animation = LottieAnimation.named(animationName)
            context.coordinator.loadedName = animationName
            uiView.play()
        } else if !uiView.isAnimationPlaying {
            uiView.play()
        }
    }
}
#endif
