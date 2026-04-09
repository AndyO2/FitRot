import AVFoundation
import Combine
import Foundation

@preconcurrency
final class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isRunning = false

    nonisolated(unsafe) let captureSession = AVCaptureSession()

    nonisolated(unsafe) var onFrameCaptured: (@Sendable (CMSampleBuffer) -> Void)?

    private let sessionQueue = DispatchQueue(label: "com.pushupcamera.session")
    private let videoOutputQueue = DispatchQueue(label: "com.pushupcamera.videoOutput")

    func requestAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    self.isAuthorized = granted
                    if granted {
                        self.startSession()
                    }
                }
            }
        default:
            isAuthorized = false
        }
    }

    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configureSession()
            self.captureSession.startRunning()
            Task { @MainActor in
                self.isRunning = true
            }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.captureSession.stopRunning()
            Task { @MainActor in
                self.isRunning = false
            }
        }
    }

    private nonisolated func configureSession() {
        guard captureSession.inputs.isEmpty else { return }

        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        captureSession.sessionPreset = .high

        // Front camera
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: .front
        ) else { return }

        guard let input = try? AVCaptureDeviceInput(device: camera) else { return }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        if let connection = videoOutput.connection(with: .video) {
            connection.videoRotationAngle = 90
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        onFrameCaptured?(sampleBuffer)
    }
}
