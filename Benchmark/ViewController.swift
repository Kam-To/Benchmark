//
//  ViewController.swift
//  Benchmark
//
//  Created by Kam on 2021/7/18.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let names = ["cat.jpg", "underpass.jpg", "wave.jpg"]
        let cnt = 5
        for fileName in names {
            print("=== \(fileName)===");
            var totalPreparing = TimeInterval(0)
            var totalDraw = TimeInterval(0)
            
autoreleasepool {
            print("\nStart PreparingForDisplay.vs.DrawInCtx");
            perfrom(iterationCnt: cnt) {
                let (preparing, draw) = comparePreparingForDisplay(fileName: fileName)
                totalPreparing += preparing
                totalDraw += draw
            }
            print("Avg cost of PreparingForDisplay  : \(totalPreparing)");
            print("Avg cost of DrawInCtx            : \(totalDraw)");
            print("End PreparingForDisplay.vs.DrawInCtx\n");
}
            print("\nStart PreparingThumbnail.vs.DrawInCtx");
            totalPreparing = TimeInterval(0)
            totalDraw = TimeInterval(0)
autoreleasepool {
            perfrom(iterationCnt: cnt) {
                let (preparing, draw) = comparePreparingThumbnail(fileName: fileName)
                totalPreparing += preparing
                totalDraw += draw
            }
            print("Avg cost of PreparingThumbnail   : \(totalPreparing)");
            print("Avg cost of DrawInCtx            : \(totalDraw)");
            print("End PreparingThumbnail.vs.DrawInCtx\n");
}

autoreleasepool {
            print("\nStart PreparingThumbnail.vs.CGImageSourceCreateThumbnail");
            totalPreparing = TimeInterval(0)
            totalDraw = TimeInterval(0)
            perfrom(iterationCnt: cnt) {
                let (preparing, draw) = compareThumbnailWithCGImageSourceCreateThumbnailAtIndex(fileName: fileName)
                totalPreparing += preparing
                totalDraw += draw
            }
            print("Avg cost of PreparingThumbnail           : \(totalPreparing)");
            print("Avg cost of CGImageSourceCreateThumbnail : \(totalDraw)");
            print("End PreparingThumbnail.vs.CGImageSourceCreateThumbnail\n");
}
            
autoreleasepool {
            print("\nStart PreparingThumbnail.vs.UIGraphicsImageRenderer");
            totalPreparing = TimeInterval(0)
            totalDraw = TimeInterval(0)
            perfrom(iterationCnt: cnt) {
                let (preparing, draw) = compareThumbnailWithUIGraphicsImageRenderer(fileName: fileName)
                totalPreparing += preparing
                totalDraw += draw
            }
            print("Avg cost of PreparingThumbnail       : \(totalPreparing)");
            print("Avg cost of UIGraphicsImageRenderer  : \(totalDraw)");
            print("End PreparingThumbnail.vs.UIGraphicsImageRenderer\n");
            print("=== \(fileName)===");
}
        }
    }
    
    func fetchImageWithName(_ fileName: String) -> UIImage {
        let components = fileName.components(separatedBy: CharacterSet.init(charactersIn: "."))
        let name = components[0]
        let ext = components[1]
        let filePath = Bundle.main.url(forResource: name, withExtension: ext)
        let image = UIImage.init(contentsOfFile: filePath!.path)!
        return image
    }
    
    func perfrom(iterationCnt:Int, closure: ()->Void) {
        for _ in 0..<iterationCnt {
            closure()
        }
    }
    
    func comparePreparingForDisplay(fileName: String) -> (TimeInterval, TimeInterval) {
        let image = fetchImageWithName(fileName)
        let imageSize = image.size
        let targetSize = imageSize
        let start = Date()

            let _ = image.preparingForDisplay()

        let mid = Date()

            UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let _ = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

        let end = Date()
        
        let costOfPreparingForDisplay = mid.timeIntervalSince(start)
        let costOfDrawInCtx = end.timeIntervalSince(mid)
        return (costOfPreparingForDisplay, costOfDrawInCtx)
    }

    func comparePreparingThumbnail(fileName: String) -> (TimeInterval, TimeInterval) {
        let image = fetchImageWithName(fileName)
        let imageSize = image.size
        let targetSize = CGSize(width: ceil(imageSize.width / 2.0), height: ceil(imageSize.height / 2.0))
        let start = Date()
            let _ = image.preparingThumbnail(of: targetSize)!
        let mid = Date()
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let _ = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        let end = Date()
        
        let costOfPreparing = mid.timeIntervalSince(start)
        let costOfDrawInCtx = end.timeIntervalSince(mid)
        return (costOfPreparing, costOfDrawInCtx)
    }
    
    
    func compareThumbnailWithCGImageSourceCreateThumbnailAtIndex(fileName: String) -> (TimeInterval, TimeInterval) {
        let image = fetchImageWithName(fileName)
        let imageSize = image.size
        let targetSize = CGSize(width: ceil(imageSize.width / 2.0), height: ceil(imageSize.height / 2.0))
        let start = Date()
            let _ = image.preparingThumbnail(of: targetSize)!
        let mid = Date()
        let components = fileName.components(separatedBy: CharacterSet.init(charactersIn: "."))
        let name = components[0]
        let ext = components[1]
        let filePath = Bundle.main.url(forResource: name, withExtension: ext)!
            let maxDimension = max(targetSize.width, targetSize.height)
            let source = CGImageSourceCreateWithURL(filePath as CFURL, nil)!
            let options = [
                kCGImageSourceCreateThumbnailFromImageAlways : true,
                kCGImageSourceCreateThumbnailWithTransform : true,
                kCGImageSourceThumbnailMaxPixelSize : maxDimension
            ] as [CFString : Any]
            let imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)!
            let _ = UIImage.init(cgImage: imageRef)
        let end = Date()
        
        let costOfCaseA = mid.timeIntervalSince(start)
        let costOfCaseB = end.timeIntervalSince(mid)
        return (costOfCaseA, costOfCaseB)
    }
    
    func compareThumbnailWithUIGraphicsImageRenderer(fileName: String) -> (TimeInterval, TimeInterval) {
        let image = fetchImageWithName(fileName)
        let imageSize = image.size
        let targetSize = CGSize(width: ceil(imageSize.width / 2.0), height: ceil(imageSize.height / 2.0))
        let start = Date()
            let _ = image.preparingThumbnail(of: targetSize)!
        let mid = Date()
            let render = UIGraphicsImageRenderer(size: targetSize)
            let _ = render.image { ctx in
                let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.width)
                image.draw(in: rect)
            }
        let end = Date()
        
        let costOfCaseA = mid.timeIntervalSince(start)
        let costOfCaseB = end.timeIntervalSince(mid)
        return (costOfCaseA, costOfCaseB)
    }
    
}

