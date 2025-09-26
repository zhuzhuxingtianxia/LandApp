import AMapNaviKit
import React

extension NSDictionary {
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2DMake(self["latitude"] as! Double, self["longitude"] as! Double)
  }

  var point: CGPoint {
    CGPoint(x: self["x"] as! Double, y: self["y"] as! Double)
  }
}

extension CLLocationCoordinate2D {
  var json: [String: Double] {
    ["latitude": latitude, "longitude": longitude]
  }
}

extension MAUserLocation {
  var json: [String: Any] {
    [
      "coords": [
        "latitude": coordinate.latitude,
        "longitude": coordinate.longitude,
        "altitude": location?.altitude ?? 0,
        "heading": heading?.trueHeading,
        "accuracy": location?.horizontalAccuracy ?? 0,
        "speed": location?.speed ?? 0,
      ],
      "timestamp": NSDate().timeIntervalSince1970 * 1000,
    ]
  }
}

extension MACoordinateRegion {
  var json: [String: Any] {
    [
      "southwest": [
        "latitude": center.latitude - span.latitudeDelta / 2,
        "longitude": center.longitude - span.longitudeDelta / 2,
      ],
      "northeast": [
        "latitude": center.latitude + span.latitudeDelta / 2,
        "longitude": center.longitude + span.longitudeDelta / 2,
      ],
    ]
  }
}

extension MAMapStatus {
  var json: [String: Any] {
    [
      "target": centerCoordinate.json,
      "zoom": zoomLevel,
      "bearing": rotationDegree,
      "tilt": cameraDegree,
    ]
  }
}

@objc public extension MAMapView {
  var cameraEvent: [String: Any] {
    [
      "cameraPosition": getMapStatus().json,
      "latLngBounds": region.json,
    ]
  }
}

extension Double {
  var cgFloat: CGFloat {
    CGFloat(self)
  }
}

extension RCTConvert {
  @objc static func MapPoiType(_ json: Any) -> AMapNaviRoutePlanPOIType {
      AMapNaviKit.AMapNaviRoutePlanPOIType(rawValue: json as! NSInteger)!
  }
}

extension RCTConvert {
  @objc static func MAMapType(_ json: Any) -> MAMapType {
      AMapNaviKit.MAMapType(rawValue: json as! NSInteger)!
  }
}

extension RCTImageLoader {
  @objc public func loadImage(_ icon: NSDictionary?, callback: @escaping (UIImage) -> Void) {
    if icon == nil {
      return
    }
    let width = icon?["width"] as? Double ?? 0
    let height = icon?["height"] as? Double ?? 0
    loadImage(
      with: RCTConvert.nsurlRequest(icon),
      size: CGSize(width: width, height: height),
      scale: RCTScreenScale(),
      clipped: false,
      resizeMode: RCTResizeMode.cover,
      progressBlock: { _, _ in },
      partialLoad: { _ in },
      completionBlock: { _, image in
        if image != nil {
          DispatchQueue.main.async {
            callback(image!)
          }
        }
      }
    )
  }
}

@objc public class ImageLoader: NSObject {
    
    @objc public static func loadImage(icon: NSDictionary?,
                         completion: @escaping (UIImage?) -> Void) {
        
        guard let iconDic = icon else{
          return completion(nil)
        }
        let width = iconDic["width"] as? Double ?? 0
        let height = iconDic["height"] as? Double ?? 0
        let uri = iconDic["uri"] ?? iconDic["url"];
        let encodedString = String(describing: uri ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: encodedString ?? "") else {
                  return completion(nil)
        }
        // 创建 URL 请求
        let request = URLRequest(url: url)
        
        // 使用 URLSession 下载图片
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // 将数据转换为 UIImage
            if let originalImage = UIImage(data: data) {
                if width > 0 && height > 0 {
                    // 调整图片大小
                    let resizedImage = self.resizeImage(originalImage, targetWidth: width, targetHeight: height)
                    DispatchQueue.main.async {
                        completion(resizedImage)
                    }
                }else {
                    DispatchQueue.main.async {
                        completion(originalImage)
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    static func resizeImage(_ image: UIImage, targetWidth: CGFloat, targetHeight: CGFloat) -> UIImage {
        let size = image.size
        
        // 计算缩放比例
        let widthRatio = targetWidth / size.width
        let heightRatio = targetHeight / size.height
        
        // 确定缩放比例，保持宽高比
        let scaleFactor = min(widthRatio, heightRatio)
        
        // 计算新的尺寸
        let scaledWidth = size.width * scaleFactor
        let scaledHeight = size.height * scaleFactor
        
        // 创建图形上下文
        UIGraphicsBeginImageContextWithOptions(CGSize(width: targetWidth, height: targetHeight), false, 0.0)
        
        // 计算绘制位置（居中）
        let xPosition = (targetWidth - scaledWidth) / 2.0
        let yPosition = (targetHeight - scaledHeight) / 2.0
        
        // 绘制图片
        image.draw(in: CGRect(x: xPosition, y: yPosition, width: scaledWidth, height: scaledHeight))
        
        // 获取新的图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}
