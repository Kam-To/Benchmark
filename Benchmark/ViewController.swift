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
    
    @IBAction func compareAPIAction(_ sender: Any) {
        compare()
    }
    
    @IBAction func checkIsDisplayableAction(_ sender: Any) {
        checkResultOfThumbnailingIsDisplayable(fileName: "cat.jpg")
    }
    
    func compare() {
        let names = ["cat.jpg", "underpass.jpg", "wave.jpg"]
        let cnt = 3
        let div = TimeInterval(cnt)
        for fileName in names {
            print("=== \(fileName)===");
            var caseA = TimeInterval(0)
            var caseB = TimeInterval(0)
            
autoreleasepool {
            print("\nStart PreparingForDisplay.vs.DrawInRect");
            perfrom(iterationCnt: cnt) {
                caseA += benchmarkPreparingForDisplay(fileName: fileName)
                caseB += benchmarkDrawInRectForDisplay(fileName: fileName)
            }
            print("Avg cost of PreparingForDisplay  : \(caseA / div)");
            print("Avg cost of DrawInRect           : \(caseB / div)");
            print("End PreparingForDisplay.vs.DrawInRect\n");
}

autoreleasepool {
            print("\nStart PreparingThumbnail.vs.DrawInRect");
            caseA = TimeInterval(0)
            caseB = TimeInterval(0)
            perfrom(iterationCnt: cnt) {
                caseA += benchmarkPreparingThumbnail(fileName: fileName)
                caseB += benchmarkThumbnailDrawInRect(fileName: fileName)
            }
            print("Avg cost of PreparingThumbnail   : \(caseA / div)");
            print("Avg cost of DrawInRect           : \(caseB / div)");
            print("End PreparingThumbnail.vs.DrawInRect\n");
}

autoreleasepool {
            print("\nStart PreparingThumbnail.vs.CGImageSourceCreateThumbnail");
            caseA = TimeInterval(0)
            caseB = TimeInterval(0)
            perfrom(iterationCnt: cnt) {
                caseA += benchmarkPreparingThumbnail(fileName: fileName)
                caseB += benchmarkThumbnailCGImageSourceCreateThumbnail(fileName: fileName)
            }
            print("Avg cost of PreparingThumbnail           : \(caseA / div)");
            print("Avg cost of CGImageSourceCreateThumbnail : \(caseB / div)");
            print("End PreparingThumbnail.vs.CGImageSourceCreateThumbnail\n");
}
            
autoreleasepool {
            print("\nStart PreparingThumbnail.vs.UIGraphicsImageRenderer");
            caseA = TimeInterval(0)
            caseB = TimeInterval(0)
            perfrom(iterationCnt: cnt) {
                caseA += benchmarkPreparingThumbnail(fileName: fileName)
                caseB += benchmarkUIGraphicsImageRenderer(fileName: fileName)
            }
            print("Avg cost of PreparingThumbnail       : \(caseA / div)");
            print("Avg cost of UIGraphicsImageRenderer  : \(caseB / div)");
            print("End PreparingThumbnail.vs.UIGraphicsImageRenderer\n");
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
    
    func benchmarkPreparingForDisplay(fileName: String) -> TimeInterval {
        let start = Date()
        let image = fetchImageWithName(fileName)
        let _ = image.preparingForDisplay()
        let end = Date()
        return end.timeIntervalSince(start)
    }
    
    func benchmarkDrawInRectForDisplay(fileName: String) -> TimeInterval {
        let start = Date()
        let image = fetchImageWithName(fileName)
        let targetSize = image.size
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let _ = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let end = Date()
        return end.timeIntervalSince(start)
    }
    
    func benchmarkPreparingThumbnail(fileName: String) -> TimeInterval {
        let start = Date()
        let image = fetchImageWithName(fileName)
        let imageSize = image.size
        let targetSize = CGSize(width: ceil(imageSize.width / 2.0), height: ceil(imageSize.height / 2.0))
        let _ = image.preparingThumbnail(of: targetSize)!
        let end = Date()
        return end.timeIntervalSince(start)
    }
    
    func benchmarkThumbnailCGImageSourceCreateThumbnail(fileName: String) -> TimeInterval {
        let start = Date()
        
        let image = fetchImageWithName(fileName)
        let imageSize = image.size
        let targetSize = CGSize(width: ceil(imageSize.width / 2.0), height: ceil(imageSize.height / 2.0))
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
        return end.timeIntervalSince(start)
    }
    
    func benchmarkThumbnailDrawInRect(fileName: String) -> TimeInterval {
        let start = Date()
        let image = fetchImageWithName(fileName)
        let imageSize = image.size
        let targetSize = CGSize(width: ceil(imageSize.width / 2.0), height: ceil(imageSize.height / 2.0))
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let _ = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let end = Date()
        return end.timeIntervalSince(start)
    }

    func benchmarkUIGraphicsImageRenderer(fileName: String) -> TimeInterval {
        let start = Date()
        let image = fetchImageWithName(fileName)
        let imageSize = image.size
        let targetSize = CGSize(width: ceil(imageSize.width / 2.0), height: ceil(imageSize.height / 2.0))
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        let _ = renderer.image { ctx in
            image.draw(in: rect)
        }
        let end = Date()
        return end.timeIntervalSince(start)
    }
    
    func checkResultOfThumbnailingIsDisplayable(fileName: String) {
        let image = fetchImageWithName(fileName)
        let imageSize = image.size
        let targetSize = CGSize(width: ceil(imageSize.width / 2.0), height: ceil(imageSize.height / 2.0))
        let scaled = image.preparingThumbnail(of: targetSize)!
        let result = scaled.preparingForDisplay()!
        assert(scaled.cgImage == result.cgImage, "should be the same cgImage object")
        print("preparingThumbnail is displayable")
    }
}

