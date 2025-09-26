package qiuxiang.amap3d.map_view

import android.view.View
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import qiuxiang.amap3d.getEventTypeConstants
import qiuxiang.amap3d.toLatLng

@Suppress("unused")
internal class MarkerManager : ViewGroupManager<MarkerView>() {
  override fun getName(): String {
    return "AMapMarker"
  }

  override fun createViewInstance(reactContext: ThemedReactContext): MarkerView {
    return MarkerView(reactContext)
  }

  override fun addView(marker: MarkerView, view: View, index: Int) {
    super.addView(marker, view, index)
  }

  override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> {
    return getEventTypeConstants("onPress", "onDrag", "onDragStart", "onDragEnd")
  }

  companion object {
    const val update = 1
  }

  override fun getCommandsMap(): Map<String, Int> {
    return mapOf("update" to update)
  }

  override fun receiveCommand(marker: MarkerView, commandId: Int, args: ReadableArray?) {
    when (commandId) {
      update -> marker.updateIcon()
    }
  }

  @ReactProp(name = "latLng")
  fun setLatLng(view: MarkerView, position: ReadableMap) {
    view.position = position.toLatLng()
  }

  @ReactProp(name = "flat")
  fun setFlat(marker: MarkerView, flat: Boolean) {
    marker.flat = flat
  }

  @ReactProp(name = "opacity")
  override fun setOpacity(marker: MarkerView, opacity: Float) {
    marker.opacity = opacity
  }

  @ReactProp(name = "draggable")
  fun setDraggable(marker: MarkerView, draggable: Boolean) {
    marker.draggable = draggable
  }

  @ReactProp(name = "zIndex")
  fun setIndex(marker: MarkerView, zIndex: Float) {
    marker.zIndex = zIndex
  }

  @ReactProp(name = "anchor")
  fun setAnchor(view: MarkerView, anchor: ReadableMap) {
    view.setAnchor(anchor.getDouble("x"), anchor.getDouble("y"))
  }

  @ReactProp(name = "icon")
  fun setIcon(view: MarkerView, icon: ReadableMap?) {
    icon?.let { view.setIcon(it) }
  }
}
