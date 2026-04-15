#if os(iOS)
import SwiftUI
import AVKit

struct VideoDemoView: View {
    let videoName: String
    let title: String
    let subtitle: String?
    let buttonText: String
    let onNext: () -> Void

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Video container
            GeometryReader { geo in
                let width = geo.size.width
                let height = width * 16 / 9 // portrait aspect ratio

                ZStack {
                    if let player {
                        VideoPlayerView(player: player)
                            .frame(width: width, height: height)
                    } else {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.secondarySystemGroupedBackground))
                            .frame(width: width, height: height)
                            .overlay {
                                ProgressView()
                            }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .frame(width: width, height: height)
            }
            .aspectRatio(9/16, contentMode: .fit)
            .padding(.horizontal, 40)

            Spacer()

            // Title
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            // Subtitle
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }

            Spacer()

            // Next button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onNext()
            } label: {
                Text(buttonText)
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
            .padding(.bottom, 16)
        }
        .onAppear { setupPlayer() }
        .onDisappear { tearDownPlayer() }
        .onChange(of: videoName) { _, _ in
            tearDownPlayer()
            setupPlayer()
        }
    }

    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mov") else { return }
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let composition = AVMutableVideoComposition(propertiesOf: asset)
        composition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
        composition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2
        composition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
        item.videoComposition = composition
        let queuePlayer = AVQueuePlayer(playerItem: item)
        queuePlayer.isMuted = true
        let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        self.player = queuePlayer
        self.looper = playerLooper
        queuePlayer.play()
    }

    private func tearDownPlayer() {
        player?.pause()
        player = nil
        looper = nil
    }
}

/// Wraps AVPlayerLayer for inline video playback without controls.
private struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView(player: player)
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

private class PlayerUIView: UIView {
    let playerLayer: AVPlayerLayer

    init(player: AVPlayer) {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        super.init(frame: .zero)
        layer.addSublayer(playerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
#endif
