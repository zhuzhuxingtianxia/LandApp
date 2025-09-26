import CoreLocation
import AMapSearchKit
import AMapLocationKit
import AMapNaviKit
import React

@objc(AMapSdk)
class AMapSdk: NSObject {
    lazy private var locationManager = {
        return AMapLocationManager()
    }()
    lazy private var sysLocationManager: CLLocationManager = {
        var locm = CLLocationManager();
        locm.delegate = self
        locm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return locm;
    }()
    // 防止CLLocationManager代理多次执行回调异常
    private var isResolved = false
    
    lazy private var search: AMapSearchAPI? = {
        var search = AMapSearchAPI()
        search?.delegate = self
        return search
    }()
    
    private var localPromiseResolve: RCTPromiseResolveBlock?
    private var localPromiseReject: RCTPromiseRejectBlock?
    private var promiseResolveDict: [String: RCTPromiseResolveBlock] = [:]
    private var promiseRejectDict: [String: RCTPromiseRejectBlock] = [:]
   
    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc func initSDK(_ apiKey: String) {
        AMapServices.shared().enableHTTPS = true
        AMapServices.shared().apiKey = apiKey
        MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
        MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
    }

    @objc func getVersion(_ resolve: RCTPromiseResolveBlock, reject _: RCTPromiseRejectBlock) {
        let version = MAMapKitVersion
        resolve(version)
    }

    // 系统定位位置信息，不使用高德接口
    @objc func getSystemLocation(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.localPromiseResolve = resolve;
        self.localPromiseReject = reject;
        
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 14.0, *) {
                if(sysLocationManager.authorizationStatus == .authorizedWhenInUse) {
                    sysLocationManager.startUpdatingLocation()
                }else {
                    sysLocationManager.requestWhenInUseAuthorization()
                }
            } else {
                // Fallback on earlier versions
            }
            
            isResolved = false
        }else {
            print("定位服务不可用")
        }
    }
    
    @objc func getLocation(_ hasReGeocode: Bool, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.locationTimeout = 6
        locationManager.reGeocodeTimeout = 3
        locationManager.requestLocation(withReGeocode: hasReGeocode, completionBlock: { [self]
            location, regeocode, error -> Void in
            if error != nil {
                reject("-1", error?.localizedDescription ?? "request location failed", error)
                return
            }
            print("formate->regionCode:\(regeocode as Any)")
            print("formate->location:\(location as Any)")
            guard let curLocation = location else {
                reject("-1", "location is nil", ComplexError(code: -1, message: "location is nil"))
                return;
            }
            
            let codableLocation = CodableCLLocation(curLocation)
            let codebleRegeocode = (regeocode != nil) ? CodableLocationReGeocode(regeocode) : nil
            let locationInfo = LocationInfo(cood: codableLocation, codebleRegeocode)
            
            if let jsonStr = jsonToString(json: locationInfo) {
                resolve(jsonStr)
            }else {
                reject("-1", "json failed ", ComplexError(code: -1, message: "json failed"))
            }
        
        })
    }
        
    
    // 逆地理编码
    @objc func reverseGeocode(_ point: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {

        let request = AMapReGeocodeSearchRequest()
        guard let latitude = point["latitude"] as? CLLocationDegrees,
              let longitude = point["longitude"] as? CLLocationDegrees else {
           reject("-1", "Latitude and Longitude are required", ComplexError(code: -1, message: "Latitude and Longitude are required"))
           return
       }

        // 设置经纬度
        request.location = AMapGeoPoint.location(withLatitude: latitude, longitude: longitude)
        
        self.promiseResolveDict[request.description] = resolve
        self.promiseRejectDict[request.description] = reject
        
        // 执行逆地理编码
        self.search?.aMapReGoecodeSearch(request)
                
    }
    // poi 搜索
    @objc func poiSearch(_ params: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock){
        localPromiseResolve = resolve
        localPromiseReject = reject
        let keyword = params.value(forKey: "keyword") as? String
        let type = params.value(forKey: "type") as? String
        let cityCode = params.value(forKey: "cityCode") as? String
        let pageSize = params.value(forKey: "pageSize") as? String
        let pageNum = params.value(forKey: "pageNum") as? String
        let around = params.value(forKey: "around") as? String
        let lon = params.value(forKey: "lon") as? String
        let lat = params.value(forKey: "lat") as? String
        print("keyword:\(keyword ?? "")")

          if (keyword == nil) {
            resolve("")
          } else {
              let numberFormater = NumberFormatter()
              
              let page = numberFormater.number(from: pageNum ?? "0")?.intValue ?? 0
              let size = numberFormater.number(from: pageSize ?? "10")?.intValue ?? 10

              
            if lon != nil && lat != nil {
                let doubleLat = numberFormater.number(from: lat!)?.doubleValue ?? 0.0
                let doubleLon = numberFormater.number(from: lon!)?.doubleValue ?? 0.0
                
                let locationPoit = AMapGeoPoint()
                locationPoit.longitude = doubleLon
                locationPoit.latitude = doubleLat
                
                let aroundRequest = AMapPOIAroundSearchRequest()
                aroundRequest.location = locationPoit
                aroundRequest.radius = numberFormater.number(from: around ?? "1000")?.intValue ?? 1000
                aroundRequest.keywords = keyword
                // 按照距离排序
                aroundRequest.sortrule = 0
                aroundRequest.page = page
                aroundRequest.offset = size
                aroundRequest.types = type ?? ""
                
                search?.aMapPOIAroundSearch(aroundRequest)
            } else {
                let request = AMapPOIKeywordsSearchRequest()
                request.keywords = keyword
                
                request.city = cityCode ?? ""
                request.types = type ?? ""
                
                request.page = page
                request.offset = size
            
                search?.aMapPOIKeywordsSearch(request)
            
            }
           
         }
    }

}

extension AMapSdk: AMapSearchDelegate {
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
       print("onReGeocodeSearchDone is start")
        var resolve = self.promiseResolveDict[request.description]
        var reject = self.promiseRejectDict[request.description]
        
        guard let regeocode = response.regeocode else {
            reject?("-1", "regeocode failed ", ComplexError(code: -1, message: "regeocode failed "))
            return;
        }
        let codebleRegeocode = CodableRegeocode(regeocode)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let encodeData = try JSONSerialization.data(withJSONObject: try JSONSerialization.jsonObject(with: try encoder.encode(codebleRegeocode), options: []), options: .prettyPrinted)
            
            if let jsonStr = String(data: encodeData , encoding: .utf8) {
                resolve?(jsonStr)
            }
        } catch  {
            reject?("-1", "json failed ", error)
        }
   }

    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if  response.count == 0 {
            localPromiseResolve?("[]")
            return
        }
        let pointsArr = response.pois ?? [AMapPOI()]
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            var jsonArray = [[String: Any]]()
            
            for item in pointsArr {
                jsonArray.append([
                    "name": item.name as Any,
                    "code": item.adcode as Any,
                    "address": item.address as Any,
                    "latitude": item.location.latitude as Any,
                    "longitude": item.location.longitude as Any,
                    "province": item.province as Any,
                    "city": item.city as Any,
                    "county": item.district as Any
                ])
            }
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
            if  let jsonString = String(data: jsonData, encoding: .utf8) {
                print("formate->jsonString: \(jsonString)")
                localPromiseResolve?(jsonString)
            }
        } catch {
            localPromiseReject?("-1", "json fail", error)
        }
    }
    
    func onNearbySearchDone(_ request: AMapNearbySearchRequest!, response: AMapNearbySearchResponse!) {
        
        let infos: [AMapNearbyUserInfo] = response.infos ?? []
        if  infos.count == 0 {
            localPromiseResolve?("[]")
            return
        }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            var jsonArray = [[String: Any]]()
            
            for item in infos {
                jsonArray.append([
                    "userID": item.userID as Any,
                    "distance": item.distance as Any,
                    "updatetime": item.updatetime as Any,
                    "latitude": item.location.latitude as Any,
                    "longitude": item.location.longitude as Any,
                ])
            }
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
            if  let jsonString = String(data: jsonData, encoding: .utf8) {
                print("formate->jsonString: \(jsonString)")
                localPromiseResolve?(jsonString)
            }
        } catch {
            localPromiseReject?("-1", "json fail", error)
        }
        
        
    }
    // 请求发生错误的回调
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        localPromiseReject?("-1", "search fail", error)
    }
    
}

// MARK: - CLLocationManagerDelegate Methods
extension AMapSdk: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            if sysLocationManager.authorizationStatus == .authorizedAlways || sysLocationManager.authorizationStatus == .authorizedWhenInUse {
                sysLocationManager.startUpdatingLocation()
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        sysLocationManager.stopUpdatingLocation()
        if isResolved { return }
        isResolved = true
        guard let location = locations.last else {
            localPromiseReject?("-1", "location is nil", ComplexError(code: -1, message: "location is nil"))
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { [self] (placemarks, error) in
            if error != nil {
                self.localPromiseReject?("-1", "location reverseGeocode error", error)
                return
            }
            
            let placemark = placemarks?.first
            let codableLocation = CodableCLLocation(location)
            let regeocode = AMapLocationReGeocode()
            regeocode.country = placemark?.country
            regeocode.province = placemark?.administrativeArea ?? placemark?.locality
            regeocode.city = placemark?.locality
            regeocode.district = placemark?.subLocality ?? placemark?.subAdministrativeArea
            regeocode.street = placemark?.thoroughfare
            regeocode.formattedAddress = placemark?.thoroughfare
            regeocode.poiName = placemark?.areasOfInterest?[0] ?? placemark?.name
            let codebleRegeocode = (placemark != nil) ? CodableLocationReGeocode(regeocode) : nil
            let locationInfo = LocationInfo(cood: codableLocation, codebleRegeocode)
            
            if let jsonStr = jsonToString(json: locationInfo) {
                self.localPromiseResolve?(jsonStr)
            }else {
                self.localPromiseReject?("-1", "json failed ", ComplexError(code: -1, message: "json failed"))
            }
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        sysLocationManager.stopUpdatingLocation()
        localPromiseReject?("-1", "location is nil", error)
    }
    
}
    
extension AMapSdk {
    func jsonToString(json: Codable) -> String? {
        if let jsonData = try? JSONEncoder().encode(json) {
            if let jsonStr = String(data: jsonData, encoding: .utf8) {
                return jsonStr
            }
        }
        return nil
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//
//        do {
//            let encodeData = try JSONSerialization.data(withJSONObject: try JSONSerialization.jsonObject(with: try encoder.encode(json), options: []), options: .prettyPrinted)
//            guard let jsonStr = String(data: encodeData , encoding: .utf8) else {
//                return nil
//            }
//            return jsonStr
//        } catch  {
//            return nil
//        }
    }

    struct CodableCLLocation: Codable  {
        let latitude: Double
        let longitude: Double
        init(_ loc: CLLocation) {
            latitude = loc.coordinate.latitude
            longitude = loc.coordinate.longitude
        }
        var location: CLLocation {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    struct CodableRegeocode: Codable {
        let country: String?
        let province: String?
        let city: String?
        let formattedAddress: String?
        let district: String?
        let citycode: String?
        let adcode: String?
        let street: String?
        let number: String?
        let poiName: String?
        let aoiName: String?

        init( _ regeocode: AMapReGeocode?) {
            let pois = regeocode?.pois
            let poi = pois?.first
            let aoi = regeocode?.aois?.first
            self.country = regeocode?.addressComponent?.country
            self.province = regeocode?.addressComponent?.province
            self.city = regeocode?.addressComponent?.city
            self.formattedAddress = regeocode?.formattedAddress
            self.district = regeocode?.addressComponent?.district
            self.citycode = regeocode?.addressComponent?.citycode
            self.adcode = regeocode?.addressComponent?.adcode
            self.street = regeocode?.addressComponent?.streetNumber.street
            self.number = regeocode?.addressComponent?.streetNumber?.number
            self.poiName = poi?.name
            self.aoiName = aoi?.name
        }
    }
    struct CodableLocationReGeocode: Codable {
        let country: String?
        let province: String?
        let city: String?
        let formattedAddress: String?
        let district: String?
        let citycode: String?
        let adcode: String?
        let street: String?
        let number: String?
        let poiName: String?
        let aoiName: String?

        init( _ regeocode: AMapLocationReGeocode?) {
            self.country = regeocode?.country
            self.province = regeocode?.province
            self.city = regeocode?.city
            self.formattedAddress = regeocode?.formattedAddress
            self.district = regeocode?.district
            self.citycode = regeocode?.citycode
            self.adcode = regeocode?.adcode
            self.street = regeocode?.street
            self.number = regeocode?.number
            self.poiName = regeocode?.poiName
            self.aoiName = regeocode?.aoiName

        }
    }
    struct LocationInfo: Codable{
        let cood: CodableCLLocation
        let regeocode: CodableLocationReGeocode?;
        let latitude: Double
        let longitude: Double

        
        init(cood: CodableCLLocation, _ regeocode: CodableLocationReGeocode?) {
            self.cood = cood
            self.regeocode = regeocode
            self.latitude = cood.latitude
            self.longitude = cood.longitude
        }
    }
    
    struct ComplexError: LocalizedError {
        let code: Int
        let message: String
        
        var errorDescription: String? {
            return "\(code): \(message)"
        }
    }
}
