package qiuxiang.amap3d.map_view

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.annotation.Nullable
import com.amap.api.maps.AMap
import com.amap.api.maps.model.*
import com.amap.api.maps.model.Marker
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.events.Event
import com.facebook.react.views.view.ReactViewGroup
import qiuxiang.amap3d.fetchImage

class MarkerView(context: Context) : ReactViewGroup(context), Overlay {
  private var view: View? = null
  private var icon: BitmapDescriptor? = null
  private var anchorX: Float = 0.5f
  private var anchorY: Float = 1f
  var marker: Marker? = null

  init {
    this.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
  }

  var position: LatLng? = null
    set(value) {
      field = value
      marker?.position = value
    }

  var zIndex: Float = 0.0f
    set(value) {
      field = value
      marker?.zIndex = value
    }

  var flat: Boolean = false
    set(value) {
      field = value
      marker?.isFlat = value
    }

  var opacity: Float = 1f
    set(value) {
      field = value
      marker?.alpha = value
    }

  var draggable: Boolean = false
    set(value) {
      field = value
      marker?.isDraggable = value
    }

  fun updateIcon() {
    view?.let {
      if (it.width != 0 && it.height != 0) {
        val bitmap = Bitmap.createBitmap(it.width, it.height, Bitmap.Config.ARGB_8888)
        it.draw(Canvas(bitmap))
        icon = BitmapDescriptorFactory.fromBitmap(bitmap)
        marker?.setIcon(icon)
      }
    }
  }

  fun setAnchor(x: Double, y: Double) {
    anchorX = x.toFloat()
    anchorY = y.toFloat()
    marker?.setAnchor(anchorX, anchorY)
  }

  override fun addView(child: View, index: Int) {
    super.addView(child, index)
    view = child
    view?.addOnLayoutChangeListener { _, _, _, _, _, _, _, _, _ -> updateIcon() }
  }
  
  fun setIcon(source: ReadableMap) {
    fetchImage(source) {
      icon = it
      Handler(Looper.getMainLooper()).post {
        marker?.setIcon(it)
      }
    }
  }

  fun receiveEvent(eventName: String, data: WritableMap? = null) {
    val reactContext = context as ReactContext
    val surfaceId = UIManagerHelper.getSurfaceId(reactContext)
    val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)

    if (eventName == "onPress") {
      println("按钮被点击了")
    } else if (eventName == "onDragStart") {
      println("onDragStart")
    }else if (eventName == "onDrag") {
      println("onDrag")
    }else if (eventName == "onDragEnd") {
      println("onDragEnd")
    }

    val payload = Arguments.createMap()
    if (data != null) {
      payload.merge(data)
    }

    val event = ActionEvent(surfaceId, id, eventName, payload)

    eventDispatcher?.dispatchEvent(event)

  }

  inner class ActionEvent(
    surfaceId: Int,
    viewId: Int,
    private val eventName: String,
    private val payload: WritableMap
  ) : Event<ActionEvent>(surfaceId, viewId) {
    override fun getEventName() = eventName

    override fun getEventData() = payload
  }

  override fun add(map: AMap) {
    marker = map.addMarker(
      MarkerOptions()
        .setFlat(flat)
        .icon(icon)
        .alpha(opacity)
        .draggable(draggable)
        .position(position)
        .anchor(anchorX, anchorY)
        .zIndex(zIndex)
        .infoWindowEnable(false)
    )
  }

  override fun remove() {
    marker?.destroy()
  }
}
