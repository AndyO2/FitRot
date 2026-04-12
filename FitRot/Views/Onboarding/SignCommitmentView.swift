#if os(iOS)
import SwiftUI
import PencilKit

struct SignatureCanvasView: UIViewRepresentable {
    @Binding var hasSignature: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .label, width: 2.5)
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.delegate = context.coordinator
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(hasSignature: $hasSignature)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var hasSignature: Bool

        init(hasSignature: Binding<Bool>) {
            _hasSignature = hasSignature
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            let isEmpty = canvasView.drawing.strokes.isEmpty
            if hasSignature != !isEmpty {
                hasSignature = !isEmpty
            }
        }
    }
}

struct SignCommitmentView: View {
    @Binding var hasSignature: Bool

    @State private var canvasID = UUID()

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign to make it official")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)

            ZStack(alignment: .topTrailing) {
                SignatureCanvasView(hasSignature: $hasSignature)
                    .id(canvasID)
                    .frame(height: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                if hasSignature {
                    Button {
                        canvasID = UUID()
                        hasSignature = false
                    } label: {
                        Text("Clear")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                    .padding(8)
                }
            }

            Text("Signed on \(formattedDate)")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
}
#endif
