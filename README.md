# Benchmark
Demo about UIImage New API in iOS 15



### Env

MacBook Air (M1, 2020) 16 GB

Xcode Version 13.0 beta (13A5155e) 



### Result

#### Runing on Simulator(iOS 15)

Display

|                     | **cat.jpg** | underpass.jpg | wave.jpg |
| ------------------- | :---------- | ------------- | -------- |
| preparingForDisplay | **0.40**    | **0.39**      | **0.50** |
| DrawInRect          | 0.96        | 0.92          | 1.30     |

Thumbnail

|                                              | **cat.jpg** | underpass.jpg | wave.jpg |
| -------------------------------------------- | ----------- | ------------- | -------- |
| preparingThumbnail                           | **0.33**    | **0.32**      | **0.59** |
| DrawInRect(CoreGraphics)                     | 1.00        | 1.00          | 1.41     |
| CGImageSourceCreateThumbnailAtIndex(ImageIO) | **0.32**    | **0.32**      | **0.57** |
| UIGraphicsImageRenderer(UIKit)               | 1.27        | 1.29          | 1.72     |



***Notice that the new API `preparingThumbnail` have almost identfical perfromance to ImageIO technique.***



#### Runing on iPhone XR(iOS 15 beta3)

Display

|                     | **cat.jpg** | underpass.jpg | wave.jpg |
| ------------------- | :---------- | ------------- | -------- |
| preparingForDisplay | **0.29**    | **0.16**      | **0.22** |
| DrawInRect          | 0.57        | 0.46          | **0.68** |

Thumbnail

|                                              | **cat.jpg** | underpass.jpg | wave.jpg |
| -------------------------------------------- | ----------- | ------------- | -------- |
| preparingThumbnail                           | **0.16**    | **0.16**      | **0.30** |
| DrawInRect(CoreGraphics)                     | 0.51        | 0.50          | 0.73     |
| CGImageSourceCreateThumbnailAtIndex(ImageIO) | **0.16**    | **0.16**      | 0.30     |
| UIGraphicsImageRenderer(UIKit)               | 0.61        | 0.64          | 0.83     |

