@objc(AMapViewManager)
class AMapViewManager: RCTViewManager {
  override class func requiresMainQueueSetup() -> Bool { false }
  private var mapview: MapView?
  override func view() -> UIView {
      
    let view = MapView()
    view.imageLoader = bridge.module(forName: "ImageLoader") as? RCTImageLoader
//    view.loadRender()
      print("load")
    view.delegate = view
    self.mapview = view
    return view
  }

  @objc func moveCamera(_ reactTag: NSNumber, position: NSDictionary, duration: Int) {
    getView(reactTag: reactTag) { view in
     
      view?.moveCamera(position: position, duration: duration)
    }
  }

  @objc func call(_ reactTag: NSNumber, callerId: Double, name: String, args: NSDictionary) {
    getView(reactTag: reactTag) { view in
      view?.call(id: callerId, name: name, args: args)
    }
  }

  func getView(reactTag: NSNumber, callback: @escaping (MapView?) -> Void) {
    //    bridge.uiManager.addUIBlock { _, viewRegistry in
//      callback(viewRegistry![reactTag] as! MapView)
//    }
      guard let view = bridge.uiManager.view(forReactTag: reactTag) else {
        return callback(self.mapview)
      }
      callback(view as? MapView)
  }
}

//针对MAAnnotationView的扩展
extension MAAnnotationView {
    
    /// 根据heading信息旋转大头针视图
    ///
    /// - Parameter heading: 方向信息
    func rotateWithHeading(heading: CLHeading) {
        
        //将设备的方向角度换算成弧度
        let headings = .pi * heading.magneticHeading / 180.0
        //创建不断旋转CALayer的transform属性的动画
        let rotateAnimation = CABasicAnimation(keyPath: "transform")
        //动画起始值
        let formValue = self.layer.transform
        rotateAnimation.fromValue = NSValue(caTransform3D: formValue)
        //绕Z轴旋转heading弧度的变换矩阵
        let toValue = CATransform3DMakeRotation(CGFloat(headings), 0, 0, 1)
        //设置动画结束值
        rotateAnimation.toValue = NSValue(caTransform3D: toValue)
        rotateAnimation.duration = 0.35
        rotateAnimation.isRemovedOnCompletion = true
        //设置动画结束后layer的变换矩阵
        self.layer.transform = toValue
        
        //添加动画
        self.layer.add(rotateAnimation, forKey: nil)
        
    }
}

class MapView: MAMapView, MAMapViewDelegate {

  var initialized = false
  var imageLoader: RCTImageLoader?
  var locationIcon: UIImage?
  var overlayMap: [MABaseOverlay: Overlay] = [:]
  var markerMap: [MAPointAnnotation: Marker] = [:]
    
    var locationImageData: NSDictionary?
  
  let locationRender: MAUserLocationRepresentation = MAUserLocationRepresentation()
    
  let locationMarker: Marker = Marker()

  var locationAnnotationView: MAAnnotationView?
    
  

  @objc var onLoad: RCTBubblingEventBlock = { _ in }
  @objc var onCameraMove: RCTBubblingEventBlock = { _ in }
  @objc var onCameraIdle: RCTBubblingEventBlock = { _ in }
  @objc var onPress: RCTBubblingEventBlock = { _ in }
  @objc var onPressPoi: RCTBubblingEventBlock = { _ in }
  @objc var onLongPress: RCTBubblingEventBlock = { _ in }
  @objc var onLocation: RCTBubblingEventBlock = { _ in }
  @objc var onCallback: RCTBubblingEventBlock = { _ in }
    
    // 属性设置
    @objc var hideLogo = false {
        didSet {
            let logoSize = logoSize
            var logoView: UIView?
            subviews.forEach { subView in
                if subView is UIImageView && subView.bounds.size == logoSize {
                    logoView = subView
                }
            }
            logoView?.isHidden = hideLogo
            logoView?.alpha = hideLogo ? 0 : 1.0
        }
    }
    @objc var accuracyRingEnabled = false {
        didSet {
            self.locationRender.showsAccuracyRing = accuracyRingEnabled
        }
    }
    @objc var headingIndicatorEnabled = false {
        didSet {
            self.locationRender.showsHeadingIndicator = headingIndicatorEnabled
        }
    }
    @objc var accuracyRingFillColor = UIColor.white {
        didSet {
            self.locationRender.fillColor = accuracyRingFillColor
        }
    }

    @objc var accuracyRingLineWidth = 1.0 {
        didSet {
            self.locationRender.lineWidth = accuracyRingLineWidth
        }
    }
    @objc var accuracyRingStokrColor = UIColor.black {
        didSet {
            self.locationRender.strokeColor = accuracyRingStokrColor
        }
    }
    @objc var pulseAnnimationEnable = false {
        didSet {
            self.locationRender.enablePulseAnnimation = pulseAnnimationEnable
        }
    }
    
    @objc var locationDotBgColor = UIColor.black {
        didSet {
            self.locationRender.locationDotBgColor = locationDotBgColor
        }
    }
    @objc var locationDotFillColor = UIColor.white {
        didSet {
            self.locationRender.locationDotFillColor = locationDotFillColor
        }
    }
    @objc var locationImage: NSDictionary?  {
        didSet {
            self.locationImageData = locationImage
            imageLoader?.loadImage(locationImage) {
                image in
                self.locationIcon = image
                
                
                if self.locationRender.image == nil {
                    self.locationRender.image = image
                    self.update(self.locationRender)
                }
                
                if self.locationAnnotationView?.image == nil {
                    self.locationAnnotationView?.image = image;
                }
                
                
            }
        }
    }
    
    @objc func setLocationIcon(_ locationI: NSDictionary?) {
      imageLoader?.loadImage(locationI) { image in
          print("加载图片----->1")
          self.locationIcon = image
          self.locationRender.image = image
      }
    }
    
   
    func loadRender()  {
        self.locationRender.showsAccuracyRing = accuracyRingEnabled
        self.locationRender.showsHeadingIndicator = headingIndicatorEnabled
        self.locationRender.fillColor = accuracyRingFillColor
        self.locationRender.lineWidth = accuracyRingLineWidth
        self.locationRender.strokeColor = accuracyRingStokrColor
        self.locationRender.enablePulseAnnimation = pulseAnnimationEnable
        self.locationRender.locationDotBgColor = locationDotBgColor
        self.locationRender.locationDotFillColor = locationDotFillColor
        print("加载图片----->2")

        
        if self.locationIcon != nil {
            self.locationRender.image = self.locationIcon
            print("加载图片----->3")
            if self.locationAnnotationView != nil {
                print("加载图片----->4")

                self.locationAnnotationView?.image = self.locationIcon
            }
            
            self.update(self.locationRender)

        } else {
//            loadImage()
//            self.setLocationImage(<#T##locationImage: NSDictionary?##NSDictionary?#>)
            print("加载图片----->else5")
            print("加载图片----->else8 \(String(describing: self.locationImageData))")
            if self.locationImageData != nil {
                print("加载图片----->else6")
                imageLoader?.loadImage(self.locationImageData) { image in
                    print("加载图片----->else7")

//                    self.locationIcon = image
//                    self.locationRender.image = image
                    
//                    self.update(self.locationRender)

                }
            } else {
                print("加载图片----->else9 \(String(describing: locationImage))")

                imageLoader?.loadImage(locationImage) {
                    image in
                    print("加载图片----->else7")
                        self.locationIcon = image
                        self.locationRender.image = image
                        
                        self.update(self.locationRender)
                }
            }

        }
        
        
            }
  
    func loadImage() {
        if self.locationImage != nil {
            imageLoader?.loadImage(self.locationImage) { image in
                
                self.locationIcon = image
                self.locationRender.image = image
            }
        }
        
    }
    
  @objc func setInitialCameraPosition(_ json: NSDictionary) {
    if !initialized {
      initialized = true
      moveCamera(position: json)
    }
  }


  func moveCamera(position: NSDictionary, duration: Int = 0) {
    let status = MAMapStatus()
    status.zoomLevel = (position["zoom"] as? Double)?.cgFloat ?? zoomLevel
    status.cameraDegree = (position["tilt"] as? Double)?.cgFloat ?? cameraDegree
    status.rotationDegree = (position["bearing"] as? Double)?.cgFloat ?? rotationDegree
    status.centerCoordinate = (position["target"] as? NSDictionary)?.coordinate ?? centerCoordinate
    setMapStatus(status, animated: true, duration: Double(duration) / 1000)
  }

  func call(id: Double, name: String, args: NSDictionary) {
    switch name {
    case "getLatLng":
      callback(id: id, data: convert(args.point, toCoordinateFrom: self).json)
    default:
      break
    }
  }



  func callback(id: Double, data: [String: Any]) {
    onCallback(["id": id, "data": data])
  }

  override func didAddSubview(_ subview: UIView) {
    if let overlay = (subview as? Overlay)?.getOverlay() {
      overlayMap[overlay] = subview as? Overlay
      add(overlay)
    }
    if let annotation = (subview as? Marker)?.annotation {
      markerMap[annotation] = subview as? Marker
      addAnnotation(annotation)
    }
  }

  override func removeReactSubview(_ subview: UIView!) {
    super.removeReactSubview(subview)
    if let overlay = (subview as? Overlay)?.getOverlay() {
      overlayMap.removeValue(forKey: overlay)
      remove(overlay)
    }
    if let annotation = (subview as? Marker)?.annotation {
      markerMap.removeValue(forKey: annotation)
      removeAnnotation(annotation)
    }
  }

  func mapView(_: MAMapView, rendererFor overlay: MAOverlay) -> MAOverlayRenderer? {
    if let key = overlay as? MABaseOverlay {
      return overlayMap[key]?.getRenderer()
    }
    return nil
  }


  func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation) -> MAAnnotationView? {
      if annotation.isKind(of: MAPointAnnotation.self) {
          let pointReuseIndetifier = "pointReuseIndetifier"
          var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as! MAPinAnnotationView?
          
          if locationAnnotationView == nil {
              annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
          }
          
          
      }
      
      if annotation is MAUserLocation {
          let userLocationIdentifier = "userLocationIdentifier"
          var userView = mapView.dequeueReusableAnnotationView(withIdentifier: userLocationIdentifier) 
          if userView == nil {
              userView = MAAnnotationView(annotation: annotation, reuseIdentifier: userLocationIdentifier)
          }
          
          if userView?.image == nil {
              if self.locationIcon != nil  {
                
                  userView?.image = self.locationIcon
              } else if self.locationImageData != nil {
                  imageLoader?.loadImage(self.locationImageData) { image in
                      self.locationIcon = image
                      self.locationRender.image = image
                      userView?.image = image
                  }

              }
          }
          
          
          
          
          
          
          self.locationAnnotationView = userView
          return userView
      }

    if let key = annotation as? MAPointAnnotation {
      return markerMap[key]?.getView()
    }
    return nil
  }

  func mapView(_: MAMapView!, annotationView view: MAAnnotationView!, didChange newState: MAAnnotationViewDragState, fromOldState _: MAAnnotationViewDragState) {
    if let key = view.annotation as? MAPointAnnotation {
      let market = markerMap[key]!
      if newState == MAAnnotationViewDragState.starting {
        market.onDragStart(nil)
      }
      if newState == MAAnnotationViewDragState.dragging {
        market.onDrag(nil)
      }
      if newState == MAAnnotationViewDragState.ending {
        market.onDragEnd(view.annotation.coordinate.json)
      }
    }
  }

  func mapView(_: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
      
    if let key = view.annotation as? MAPointAnnotation {
      markerMap[key]?.onPress(nil)
    }
  }

  func mapInitComplete(_: MAMapView!) {
    onLoad(nil)
  }

  func mapView(_: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
    onPress(coordinate.json)
  }



  func mapView(_: MAMapView!, didTouchPois pois: [Any]!) {
    let poi = pois[0] as! MATouchPoi
    onPressPoi(["name": poi.name!, "id": poi.uid!, "position": poi.coordinate.json])
  }

    
    
  func mapView(_: MAMapView!, didLongPressedAt coordinate: CLLocationCoordinate2D) {
    onLongPress(coordinate.json)

  }

  func mapViewRegionChanged(_: MAMapView!) {
    onCameraMove(cameraEvent)
  }

  func mapView(_: MAMapView!, regionDidChangeAnimated _: Bool) {
    onCameraIdle(cameraEvent)
  }

  func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation : Bool) {
      if !updatingLocation {
          let userView = mapView.view(for: userLocation)
          let userHeading = userLocation.heading;
//          print(userHeading as Any)
          
          if userHeading != nil {
              userView?.rotateWithHeading(heading: userHeading!)

          }
      }
      
//      if !updatingLocation && locationAnnotationView != nil {
//          
//          
//          UIView.animate(withDuration: 0.1, delay: 0.1, usingSpringWithDamping: CGFloat(0.1), initialSpringVelocity: CGFloat(0.1), animations: {
//              let transform = CGAffineTransform(rotationAngle: CGFloat(userLocation.heading.trueHeading) - mapView.rotationDegree)
//              print(CGFloat(userLocation.heading.trueHeading) - mapView.rotationDegree)
//              
//              self.locationAnnotationView?.transform = transform
//              
//              
//              
//          }
//              
//          )
//      }
    
    onLocation(userLocation.json)
  }
}
