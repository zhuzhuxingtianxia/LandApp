package qiuxiang.amap3d.map_view

//import android.util.Log
//import android.view.View
//import com.facebook.react.bridge.ReactApplicationContext
//import com.facebook.react.bridge.ReadableArray
//import com.facebook.react.bridge.ReadableMap
//import com.facebook.react.module.annotations.ReactModule
//import com.facebook.react.uimanager.ThemedReactContext
//import com.facebook.react.uimanager.ViewGroupManager
//import com.facebook.react.uimanager.ViewManagerDelegate
//import com.facebook.react.uimanager.annotations.ReactProp
//import com.facebook.react.viewmanagers.MapMarkerManagerDelegate
//import com.facebook.react.viewmanagers.MapMarkerManagerInterface
//import qiuxiang.amap3d.getEventTypeConstants
//import qiuxiang.amap3d.toLatLng
//
//@ReactModule(name = MarkerManager.NAME)
//internal class MarkerManager(context: ReactApplicationContext) : ViewGroupManager<MarkerView>(),
//  MapMarkerManagerInterface<MarkerView> {
//
//  private val mDelegate: MapMarkerManagerDelegate<MarkerView, MarkerManager>
//
//  init {
//    mDelegate = MapMarkerManagerDelegate(this)
//  }
//
//  override fun getDelegate(): ViewManagerDelegate<MarkerView> {
//    return mDelegate
//  }
//
//  override fun getName(): String {
//    return NAME
//  }
//
//  companion object {
//    // 老架构
////    const val NAME = "AMapMarker"
//    // 新架构
//    const val NAME = "MapMarker"
//    const val update = 1
//  }
//
//  override fun createViewInstance(reactContext: ThemedReactContext): MarkerView {
//    return MarkerView(reactContext)
//  }
//
//  override fun addView(parent: MarkerView, child: View, index: Int) {
////    super.addView(parent, child, index)
//    parent.addView(child, index)
//    // 请求重新布局
//    parent.requestLayout()
//  }
//  // 处理子视图的移除
//  override fun removeViewAt(parent: MarkerView, index: Int) {
//    parent.removeViewAt(index)
//    // 请求重新布局
//    parent.requestLayout()
//  }
//
//  // 获取子视图数量
//  override fun getChildCount(parent: MarkerView): Int {
//    return parent.childCount
//  }
//
//  // 获取指定位置的子视图
//  override fun getChildAt(parent: MarkerView, index: Int): View {
//    return parent.getChildAt(index)
//  }
//
//  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
//    return getEventTypeConstants("onPress", "onDrag", "onDragStart", "onDragEnd")
//  }
//
//  override fun getCommandsMap(): Map<String, Int> {
//    return mapOf("update" to update)
//  }
//
//  override fun receiveCommand(marker: MarkerView, commandId: Int, args: ReadableArray?) {
//    when (commandId) {
//      update -> marker.updateIcon()
//    }
//  }
//
//  @ReactProp(name = "latLng")
//  fun setLatLng(view: MarkerView, position: ReadableMap) {
//    view.position = position.toLatLng()
//  }
//
//  @ReactProp(name = "flat")
//  override fun setFlat(marker: MarkerView, flat: Boolean) {
//    marker.flat = flat
//  }
//
//  @ReactProp(name = "opacity")
//  override fun setOpacity(marker: MarkerView, opacity: Float) {
//    marker.opacity = opacity
//  }
//
//  @ReactProp(name = "draggable")
//  override fun setDraggable(marker: MarkerView, draggable: Boolean) {
//    marker.draggable = draggable
//  }
//
//  @ReactProp(name = "zIndex")
//  fun setZIndex(view: MarkerView?, value: Int) {
//    if (view != null) {
//      view.zIndex = value.toFloat()
//    }
//  }
//  override fun setMarkerIndex(view: MarkerView?, value: Int) {
//    if (view != null) {
//      view.zIndex = value.toFloat()
//    }
//  }
//
//  @ReactProp(name = "anchor")
//  fun setAnchor(view: MarkerView, anchor: ReadableMap) {
//    view.setAnchor(anchor.getDouble("x"), anchor.getDouble("y"))
//  }
//
//  @ReactProp(name = "icon")
//  override fun setIcon(view: MarkerView, icon: ReadableMap?) {
//    icon?.let { view.setIcon(it) }
//  }
//
//  override fun setPosition(view: MarkerView?, value: ReadableMap?) {
//    if (value != null) {
//      if (view != null) {
//        view.position = value.toLatLng()
//      }
//    }
//  }
//
//  override fun setCenterOffset(view: MarkerView?, value: ReadableMap?) {
//    if (value != null) {
//      if (view != null) {
//        Log.d(NAME, value.toString())
//      }
//    }
//  }
//
//  override fun update(view: MarkerView?) {
//    view?.updateIcon()
//  }
//}
