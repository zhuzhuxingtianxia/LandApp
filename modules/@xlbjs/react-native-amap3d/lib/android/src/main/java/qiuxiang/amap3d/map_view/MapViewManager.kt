package qiuxiang.amap3d.map_view

import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.View
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.model.CustomMapStyleOptions
import com.amap.api.maps.model.MyLocationStyle
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import qiuxiang.amap3d.getEventTypeConstants
import qiuxiang.amap3d.toLatLng
import qiuxiang.amap3d.toPx
import java.lang.ref.WeakReference

@Suppress("unused")
internal class MapViewManager : ViewGroupManager<MapView>() {
  private val commands = mapOf(
    "moveCamera" to { view: MapView, args: ReadableArray? -> view.moveCamera(args) },
    "call" to { view: MapView, args: ReadableArray? -> view.call(args) },
  )

  override fun getName(): String {
    return "AMapView"
  }

  override fun createViewInstance(reactContext: ThemedReactContext): MapView {
    return MapView(reactContext)
  }

  override fun onDropViewInstance(view: MapView) {
    super.onDropViewInstance(view)
    //    view.onDestroy()
    val weakView = WeakReference(view)
    Handler(Looper.getMainLooper()).postDelayed({
      weakView.get()?.onDestroy()
    }, 300)
  }

  override fun getCommandsMap(): Map<String, Int> {
    return commands.keys.mapIndexed { index, key -> key to index }.toMap()
  }

  override fun receiveCommand(view: MapView, command: Int, args: ReadableArray?) {
    commands.values.toList()[command](view, args)
  }

  override fun addView(mapView: MapView, child: View, index: Int) {
    mapView.add(child)
    super.addView(mapView, child, index)
  }

  override fun removeViewAt(parent: MapView, index: Int) {
    parent.remove(parent.getChildAt(index))
    super.removeViewAt(parent, index)
  }

  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
    return getEventTypeConstants(
      "onLoad",
      "onPress",
      "onPressPoi",
      "onLongPress",
      "onCameraMove",
      "onCameraIdle",
      "onLocation",
      "onCallback",
    )
  }

  @ReactProp(name = "initialCameraPosition")
  fun setInitialCameraPosition(view: MapView, position: ReadableMap) {
    view.setInitialCameraPosition(position)
  }

  @ReactProp(name = "myLocationEnabled")
  fun setMyLocationEnabled(view: MapView, enabled: Boolean) {
    view.map.isMyLocationEnabled = enabled
  }

  // todo 隐藏logo
  @ReactProp(name = "hideLogo")
  fun setHideLogo(view: MapView, hide: Boolean) {
    val setting = view.map.uiSettings
    setting.setLogoBottomMargin(if (hide) -100 else 0)
  }
  // todo 自定义地图
  @ReactProp(name = "customStyleOptions")
  fun setCustomStyleOptions(view: MapView, options: ReadableMap?) {
    options?.let { view.setCustomStyleOptions(options) }
  }

  // todo 精度圈是否开启
  @ReactProp(name = "accuracyRingEnabled")
  fun setAccuracyRingEnabledview (view: MapView, enabled: Boolean) {
    val locationStyle = view.getLocationStyle()

    if (!enabled) {
      locationStyle.radiusFillColor(Color.argb(0, 255,255,255))
      val zeroInt = 0
      locationStyle.strokeWidth(zeroInt.toFloat())

      locationStyle.strokeColor(Color.argb(0, 255,255,255))
      view.setLocationStyle(locationStyle)
    }
  }

  // todo 指向箭头是否开启
  @ReactProp(name = "headingIndicatorEnabled")
  fun setHeadingIndicatorEnabled (view: MapView, enabled: Boolean) {
    val locationStyle = view.getLocationStyle()

    if (!enabled) {
      locationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_SHOW)
    } else {
      locationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER)
    }
    view.setLocationStyle(locationStyle)
  }

  // todo 精度圈填充色
  @ReactProp(name = "accuracyRingFillColor", customType = "Color")
  fun setAccuracyRingFillColor (view: MapView, color: Int) {
    val locationStyle = view.getLocationStyle()
    locationStyle.radiusFillColor(color)
    view.setLocationStyle(locationStyle)
  }


  // todo 精度圈线的颜色
  @ReactProp(name = "accuracyRingStrokeColor", customType = "Color")
  fun setAccuracyRingStrokeColor (view: MapView, color: Int) {
    val locationStyle = view.getLocationStyle()
    locationStyle.strokeColor(color)
    view.setLocationStyle(locationStyle)
  }

  // todo 精度圈线的线宽
  @ReactProp(name = "accuracyRingLineWidth")
  fun setAccuracyRingLineWidth(view: MapView, strokeWidth: Float) {
    val locationStyle = view.getLocationStyle()
    locationStyle.strokeWidth(strokeWidth.toPx().toFloat())
    view.setLocationStyle(locationStyle)
  }

  // todo icon
  @ReactProp(name = "locationImage")
  fun setLocationImage(view: MapView, icon: ReadableMap?) {
    icon?.let { view.setLocationImage(icon) }
  }

  @ReactProp(name = "indoorViewEnabled")
  fun setIndoorViewEnabled(view: MapView, enabled: Boolean) {
    view.map.showIndoorMap(enabled)
  }

  @ReactProp(name = "buildingsEnabled")
  fun setBuildingsEnabled(view: MapView, enabled: Boolean) {
    view.map.showBuildings(enabled)
  }

  @ReactProp(name = "compassEnabled")
  fun setCompassEnabled(view: MapView, show: Boolean) {
    view.map.uiSettings.isCompassEnabled = show
  }

  @ReactProp(name = "zoomControlsEnabled")
  fun setZoomControlsEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isZoomControlsEnabled = enabled
  }

  @ReactProp(name = "scaleControlsEnabled")
  fun setScaleControlsEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isScaleControlsEnabled = enabled
  }

  @ReactProp(name = "language")
  fun setLanguage(view: MapView, language: String) {
    view.map.setMapLanguage(language)
  }

  @ReactProp(name = "myLocationButtonEnabled")
  fun setMyLocationButtonEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isMyLocationButtonEnabled = enabled
  }

  @ReactProp(name = "trafficEnabled")
  fun setTrafficEnabled(view: MapView, enabled: Boolean) {
    view.map.isTrafficEnabled = enabled
  }

  @ReactProp(name = "maxZoom")
  fun setMaxZoom(view: MapView, zoomLevel: Float) {
    view.map.maxZoomLevel = zoomLevel
  }

  @ReactProp(name = "minZoom")
  fun setMinZoom(view: MapView, zoomLevel: Float) {
    view.map.minZoomLevel = zoomLevel
  }

  @ReactProp(name = "mapType")
  fun setMapType(view: MapView, mapType: Int) {
    view.map.mapType = mapType + 1
  }

  @ReactProp(name = "zoomGesturesEnabled")
  fun setZoomGesturesEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isZoomGesturesEnabled = enabled
  }

  @ReactProp(name = "scrollGesturesEnabled")
  fun setScrollGesturesEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isScrollGesturesEnabled = enabled
  }

  @ReactProp(name = "rotateGesturesEnabled")
  fun setRotateGesturesEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isRotateGesturesEnabled = enabled
  }

  @ReactProp(name = "tiltGesturesEnabled")
  fun setTiltGesturesEnabled(view: MapView, enabled: Boolean) {
    view.map.uiSettings.isTiltGesturesEnabled = enabled
  }

  @ReactProp(name = "cameraPosition")
  fun setCameraPosition(view: MapView, center: ReadableMap) {
    view.map.moveCamera(CameraUpdateFactory.changeLatLng(center.toLatLng()))
  }
}