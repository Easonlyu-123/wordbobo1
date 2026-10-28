//
//  OCRService.swift
//  WordBoBo
//

import Foundation
import SwiftUI
import Vision

class OCRService: ObservableObject {
    @Published var isProcessing = false
    @Published var recognizedText = ""
    @Published var errorMessage: String?

    func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
        isProcessing = true
        errorMessage = nil

        guard let cgImage = image.cgImage else {
            isProcessing = false
            errorMessage = "无法处理图片"
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isProcessing = false
                if let error = error {
                    self.errorMessage = "识别失败: \(error.localizedDescription)"
                    completion("")
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    completion("")
                    return
                }

                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
                let text = recognizedStrings.joined(separator: "\n")
                completion(text)
            }
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en", "zh-Hans"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "识别出错: \(error.localizedDescription)"
                    completion("")
                }
            }
        }
    }
}
