import AMapNaviKit
import React

@objc(AMapMarkerManager)
class AMapMarkerManager: RCTViewManager {
  override class func requiresMainQueueSetup() -> Bool { false }

  override func view() -> UIView {
    let view = Marker()
    view.imageLoader = bridge.module(forName: "ImageLoader") as? RCTImageLoader
    return view
  }

  @objc func update(_ reactTag: NSNumber) {
    getView(reactTag: reactTag) { view in view.update() }
  }

  func getView(reactTag: NSNumber, callback: @escaping (Marker) -> Void) {
    bridge.uiManager.addUIBlock { _, viewRegistry in
      callback(viewRegistry![reactTag] as! Marker)
    }
  }
}

@objc(MarkerView)
public class Marker: UIView {
  var imageLoader: RCTImageLoader?
  var view: MAAnnotationView?
  @objc public var annotation = MAPointAnnotation()
  var icon: UIImage?
  var iconView: UIView?
  var centerOffset: CGPoint?

  @objc public var draggable = false { didSet { view?.isDraggable = draggable } }
  @objc var zIndex = 1 { didSet { view?.zIndex = zIndex } }

  @objc public var onPress: RCTDirectEventBlock = { _ in }
  @objc public var onDragStart: RCTDirectEventBlock = { _ in }
  @objc public var onDrag: RCTDirectEventBlock = { _ in }
  @objc public var onDragEnd: RCTDirectEventBlock = { _ in }

  @objc func setIcon(_ icon: NSDictionary?) {
    imageLoader?.loadImage(icon) { image in
      self.icon = image
      self.view?.image = image
      self.updateCenterOffset()
    }
  }

  @objc public func setLatLng(_ coordinate: CLLocationCoordinate2D) {
    annotation.coordinate = coordinate
  }

  @objc public func setCenterOffset(_ centerOffset: CGPoint) {
    self.centerOffset = centerOffset
    view?.centerOffset = centerOffset
  }

  public override func didAddSubview(_ subview: UIView) {
    subview.layer.opacity = 0
    iconView = subview
  }

  /**
   * subview 不能直接用作 marker 的 icon，因为在实现点聚合的时候发现，subview 一定概率无法正常 layout，会堆在右上角。
   * 于是索性把 subview 渲染成 image，原来用 subview 带来的 offset、点击问题也都不用处理了。
   * 正常情况下就把 subview 的 opacity 设成 0，需要渲染的时候才设成 1，渲染然后马上设回 0。
   */
  @objc public func update() {
    if centerOffset == nil, view != nil {
      iconView?.layer.opacity = 1
      let renderer = UIGraphicsImageRenderer(bounds: iconView!.bounds)
      view?.image = renderer.image { context in layer.render(in: context.cgContext) }
      iconView?.layer.opacity = 0
      updateCenterOffset()
    }
  }

  func updateCenterOffset() {
    if centerOffset == nil, view != nil {
      let size: CGSize = (view?.image.size)!
      view?.centerOffset = CGPoint(x: 0, y: -size.height / 2)
    }
  }

  @objc public func getView() -> MAAnnotationView {
    if view == nil {
      view = MAAnnotationView(annotation: annotation, reuseIdentifier: nil)
      if icon == nil, iconView == nil {
        let renderer = UIGraphicsImageRenderer(bounds: UIView(frame: CGRect(x: 0, y: 0, width: 2, height: 2)).bounds)
          view?.image = renderer.image { context in layer.render(in: context.cgContext) }
//        view?.image = MAPinAnnotationView(annotation: annotation, reuseIdentifier: nil).image
      }
      view?.isDraggable = draggable
      view?.zIndex = zIndex
      if centerOffset != nil {
        view?.centerOffset = centerOffset!
      }
      if icon != nil {
        view?.image = icon
        updateCenterOffset()
      }
    }
    return view!
  }
}
