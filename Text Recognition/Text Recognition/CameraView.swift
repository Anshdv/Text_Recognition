//
//  CameraView.swift
//  Text Recognition
//
//  Created by Ansh D on 6/28/24.
//

import Foundation
import UIKit
import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    typealias UIViewControllerType = UIImagePickerController
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let view_controller = UIViewControllerType()
        
        view_controller.delegate = context.coordinator
        view_controller.sourceType = .camera
        view_controller.cameraDevice = .rear
        view_controller.cameraOverlayView = .none
        
        return view_controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

extension CameraView {
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                // Resize the image immediately after capture
                let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 1000, height: 1000))
                self.parent.image = resizedImage
            }
        }
        
        func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
            let size = image.size

            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height

            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }

            let rect = CGRect(origin: .zero, size: newSize)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage
        }
    }
}

extension UIImage {
    func image_resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
