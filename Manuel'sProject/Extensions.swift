//
//  Extensions.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 1/4/22.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

@available(iOS, deprecated: 15.0, message: "Usa la API real en su lugar")
extension URLSession {
    func data(from url:URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    if let error = error {
                        return continuation.resume(throwing: error)
                    } else {
                        return continuation.resume(throwing: URLError(.badServerResponse))
                    }
                }
                continuation.resume(returning: (data, response))
            }.resume()
        })
    }

    func data(for url:URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    if let error = error {
                        return continuation.resume(throwing: error)
                    } else {
                        return continuation.resume(throwing: URLError(.badServerResponse))
                    }
                }
                continuation.resume(returning: (data, response))
            }.resume()
        })
    }
}

extension UIImage {
    func resizeImage(width:CGFloat) -> UIImage? {
        let resize = CIFilter.lanczosScaleTransform()
        guard let cgImg = cgImage else { return nil }
        resize.inputImage = CIImage(cgImage: cgImg)
        resize.scale = Float(width / size.width)
        resize.aspectRatio = 1.0
        let context = CIContext(options: nil)
        if let output = resize.outputImage,
           let cgImgResized = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImgResized)
        } else {
            return nil
        }
    }
}

