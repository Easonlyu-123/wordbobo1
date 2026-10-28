//
//  CameraPreviewView.swift
//  WordBoBo
//

import SwiftUI

struct CameraPreviewView: View {
    @EnvironmentObject var ocrService: OCRService
    @EnvironmentObject var wordStore: WordStore

    @State private var image: UIImage?
    @State private var recognizedWords: [Word] = []
    @State private var isProcessing = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Button("取消") {
                        reset()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()

                    Spacer()

                    if !recognizedWords.isEmpty {
                        Text("识别到 \(recognizedWords.count) 个单词")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Spacer()

                    Button("确认") {
                        guard !recognizedWords.isEmpty else { return }
                        NotificationCenter.default.post(name: .showWordConfirm, object: nil)
                        UserDefaults.standard.set(try? JSONEncoder().encode(recognizedWords), forKey: "pendingWords")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.cyan)
                    .padding()
                    .disabled(recognizedWords.isEmpty)
                }

                Spacer()

                if recognizedWords.isEmpty && !isProcessing {
                    VStack(spacing: 16) {
                        Text("正在等待拍照...")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.bottom, 100)
                }

                if isProcessing {
                    VStack(spacing: 16) {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .cyan)).scaleEffect(1.5)
                        Text("正在识别文字...").font(.headline).foregroundStyle(.white)
                    }
                    .padding(.bottom, 100)
                }
            }

            if let error = errorMessage {
                VStack {
                    Text(error).font(.subheadline).foregroundStyle(.red)
                        .padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12)).padding()
                    Spacer()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = CameraCoordinator(parent: self)
                findTopViewController()?.present(picker, animated: true)
            }
        }
    }

    private func reset() {
        image = nil
        recognizedWords = []
        isProcessing = false
        errorMessage = nil
        findTopViewController()?.dismiss(animated: true)
    }

    private func findTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return nil }
        return window.rootViewController?.topMostViewController()
    }
}

class CameraCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var parent: CameraPreviewView?

    init(parent: CameraPreviewView) {
        self.parent = parent
    }

    func imagePickerControllerDidCancel(_ controller: UIImagePickerController) {
        controller.dismiss(animated: true) { self.parent?.reset() }
    }

    func imagePickerController(_ controller: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        controller.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else {
            self.parent?.isProcessing = false
            return
        }

        self.parent?.image = image
        self.parent?.isProcessing = true

        let enhanced = enhanceImage(image)
        OCRService().recognizeText(from: enhanced) { text in
            let words: [Word]
            if text.isEmpty {
                let raw = text.components(separatedBy: .whitespacesAndNewlines)
                    .filter { !$0.isEmpty && $0.rangeOfCharacter(from: CharacterSet.letters) != nil }
                words = raw.map { Word(text: $0) }
            } else {
                words = self.parent?.wordStore.parseWords(from: text) ?? []
                if words.isEmpty {
                    let raw = text.components(separatedBy: .whitespacesAndNewlines)
                        .filter { !$0.isEmpty && $0.rangeOfCharacter(from: CharacterSet.letters) != nil }
                    words = raw.map { Word(text: $0) }
                }
            }
            self.parent?.recognizedWords = words
            self.parent?.isProcessing = false
        }
    }

    private func enhanceImage(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let context = CIContext()
        guard let ciImage = CIImage(cgImage: cgImage) else { return image }
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(1.5, forKey: kCIInputContrastKey)
        filter.setValue(0.1, forKey: kCIInputBrightnessKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        guard let output = filter.outputImage,
              let result = context.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: result)
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController { return presented.topMostViewController() }
        if let nav = self as? UINavigationController { return nav.visibleViewController?.topMostViewController() ?? self }
        if let tab = self as? UITabBarController { return tab.selectedViewController?.topMostViewController() ?? self }
        for child in children {
            if let top = child.topMostViewController() { return top }
        }
        return self
    }
}
