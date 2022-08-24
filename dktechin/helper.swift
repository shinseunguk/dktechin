//
//  helper.swift
//  dktechin
//
//  Created by ukBook on 2022/08/24.
//

import Foundation
import UIKit
class helper : UIViewController {
    
}

extension UIImageView {
    func image(at rect: CGRect) -> UIImage? {
        guard
            let image = image,
            let rect = convertToImageCoordinates(rect)
        else {
            return nil
        }

        return image.cropped(to: rect)
    }

    func convertToImageCoordinates(_ rect: CGRect) -> CGRect? {
        guard let image = image else { return nil }
        print("\(#function) ",image.size.width)
        print("\(#function) ",image.size.height)

        let imageSize = CGSize(width: image.size.width, height: image.size.height)
        let imageCenter = CGPoint(x: imageSize.width / 2, y: imageSize.height / 2)

        let imageViewRatio = bounds.width / bounds.height
        let imageRatio = imageSize.width / imageSize.height

        let scale: CGPoint

        switch contentMode {
        case .scaleToFill:
            scale = CGPoint(x: imageSize.width / bounds.width, y: imageSize.height / bounds.height)
            print("1!")

        case .scaleAspectFit:
            let value: CGFloat
            if imageRatio < imageViewRatio {
                value = imageSize.height / bounds.height
            } else {
                value = imageSize.width / bounds.width
            }
            scale = CGPoint(x: value, y: value)
            print("2!")
        case .scaleAspectFill:
            let value: CGFloat
            if imageRatio > imageViewRatio {
                value = imageSize.height / bounds.height
            } else {
                value = imageSize.width / bounds.width
            }
            scale = CGPoint(x: value, y: value)
            print("3!")
        case .center:
            scale = CGPoint(x: 1, y: 1)
            print("4!")
        default:
            fatalError("Unexpected contentMode")
            print("5!")
        }

        var rect = rect
        if rect.width < 0 {
            rect.origin.x += rect.width
            rect.size.width = -rect.width
        }

        if rect.height < 0 {
            rect.origin.y += rect.height
            rect.size.height = -rect.height
        }

        return CGRect(x: (rect.minX - bounds.midX) * scale.x + imageCenter.x,
                      y: (rect.minY - bounds.midY) * scale.y + imageCenter.y,
                      width: rect.width * scale.x,
                      height: rect.height * scale.y)
    }
}

extension UIImage {

    /// Resize the image to be the required size, stretching it as needed.
    ///
    /// - parameter newSize:      The new size of the image.
    /// - parameter contentMode:  The `UIView.ContentMode` to be applied when resizing image.
    ///                           Either `.scaleToFill`, `.scaleAspectFill`, or `.scaleAspectFit`.
    ///
    /// - returns:                Return `UIImage` of resized image.

    func scaled(to newSize: CGSize, contentMode: UIView.ContentMode = .scaleToFill) -> UIImage? {
        switch contentMode {
        case .scaleToFill:
            return filled(to: newSize)

        case .scaleAspectFill, .scaleAspectFit:
            let horizontalRatio = size.width  / newSize.width
            let verticalRatio   = size.height / newSize.height

            let ratio: CGFloat!
            if contentMode == .scaleAspectFill {
                ratio = min(horizontalRatio, verticalRatio)
            } else {
                ratio = max(horizontalRatio, verticalRatio)
            }

            let sizeForAspectScale = CGSize(width: size.width / ratio, height: size.height / ratio)
            let image = filled(to: sizeForAspectScale)
            let doesAspectFitNeedCropping = contentMode == .scaleAspectFit && (newSize.width > sizeForAspectScale.width || newSize.height > sizeForAspectScale.height)
            if contentMode == .scaleAspectFill || doesAspectFitNeedCropping {
                let subRect = CGRect(
                    x: floor((sizeForAspectScale.width - newSize.width) / 2.0),
                    y: floor((sizeForAspectScale.height - newSize.height) / 2.0),
                    width: newSize.width,
                    height: newSize.height)
                return image?.cropped(to: subRect)
            }
            return image

        default:
            return nil
        }
    }

    /// Resize the image to be the required size, stretching it as needed.
    ///
    /// - parameter newSize:   The new size of the image.
    ///
    /// - returns:             Resized `UIImage` of resized image.

    func filled(to newSize: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = scale

        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Crop the image to be the required size.
    ///
    /// - parameter bounds:    The bounds to which the new image should be cropped.
    ///
    /// - returns:             Cropped `UIImage`.

    func cropped(to bounds: CGRect) -> UIImage? {
        // if bounds is entirely within image, do simple CGImage `cropping` ...

        if CGRect(origin: .zero, size: size).contains(bounds), imageOrientation == .up, let cgImage = cgImage {
            return cgImage.cropping(to: bounds * scale).flatMap {
                UIImage(cgImage: $0, scale: scale, orientation: imageOrientation)
            }
        }

        // ... otherwise, manually render whole image, only drawing what we need

        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = scale

        return UIGraphicsImageRenderer(size: bounds.size, format: format).image { _ in
            let origin = CGPoint(x: -bounds.minX, y: -bounds.minY)
            draw(in: CGRect(origin: origin, size: size))
        }
    }

    /// Resize the image to fill the rectange of the specified size, preserving the aspect ratio, trimming if needed.
    ///
    /// - parameter newSize:   The new size of the image.
    ///
    /// - returns:             Return `UIImage` of resized image.

    func scaledAspectFill(to newSize: CGSize) -> UIImage? {
        return scaled(to: newSize, contentMode: .scaleAspectFill)
    }

    /// Resize the image to fit within the required size, preserving the aspect ratio, with no trimming taking place.
    ///
    /// - parameter newSize:   The new size of the image.
    ///
    /// - returns:             Return `UIImage` of resized image.

    func scaledAspectFit(to newSize: CGSize) -> UIImage? {
        return scaled(to: newSize, contentMode: .scaleAspectFit)
    }

}

extension CGSize {
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

extension CGPoint {
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

extension CGRect {
    static func * (lhs: CGRect, rhs: CGFloat) -> CGRect {
        return CGRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
    }
}

