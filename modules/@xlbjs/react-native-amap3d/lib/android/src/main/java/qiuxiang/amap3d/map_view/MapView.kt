package qiuxiang.amap3d.map_view

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Resources
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.WindowManager
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.TextureMapView
import com.amap.api.maps.model.BitmapDescriptor
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.CustomMapStyleOptions
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.MyLocationStyle
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.uimanager.ThemedReactContext
import qiuxiang.amap3d.fetchImage
import qiuxiang.amap3d.getFloat
import qiuxiang.amap3d.toJson
import qiuxiang.amap3d.toLatLng
import qiuxiang.amap3d.toPoint
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.net.URL

@SuppressLint("ViewConstructor")
class MapView(context: ThemedReactContext) : TextureMapView(context) {
  @Suppress("Deprecation")
  private val eventEmitter =
    context.getJSModule(com.facebook.react.uimanager.events.RCTEventEmitter::class.java)
  private val markerMap = HashMap<String, qiuxiang.amap3d.map_view.MarkerView>()
  private val polylineMap = HashMap<String, Polyline>()
  private var initialCameraPosition: ReadableMap? = null
  private var locationStyle: MyLocationStyle
  private var image: BitmapDescriptor? = null


  fun getLocationStyle (): MyLocationStyle {
    return locationStyle
  }

  fun setLocationStyle (_locationStyle: MyLocationStyle) {
    locationStyle = _locationStyle;
    map.myLocationStyle = locationStyle;
  }

  init {
    super.onCreate(null)

    locationStyle = MyLocationStyle()
    locationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER)
    map.myLocationStyle = locationStyle

    map.setOnMapLoadedListener { emit(id, "onLoad") }
    map.setOnMapClickListener { latLng -> emit(id, "onPress", latLng.toJson()) }
    map.setOnPOIClickListener { poi -> emit(id, "onPressPoi", poi.toJson()) }
    map.setOnMapLongClickListener { latLng -> emit(id, "onLongPress", latLng.toJson()) }
    map.setOnPolylineClickListener { polyline -> emit(polylineMap[polyline.id]?.id, "onPress") }

    map.setOnMarkerClickListener { marker ->
      markerMap[marker.id]?.let { emit(it.id, "onPress") }
      dispatchEvent(markerMap[marker.id], "onPress")
      true
    }

    map.setOnMarkerDragListener(object : AMap.OnMarkerDragListener {
      override fun onMarkerDragStart(marker: Marker) {
        emit(markerMap[marker.id]?.id, "onDragStart")
        dispatchEvent(markerMap[marker.id], "onDragStart")
      }

      override fun onMarkerDrag(marker: Marker) {
        emit(markerMap[marker.id]?.id, "onDrag")
        dispatchEvent(markerMap[marker.id], "onDrag")
      }

      override fun onMarkerDragEnd(marker: Marker) {
        emit(markerMap[marker.id]?.id, "onDragEnd", marker.position.toJson())
        dispatchEvent(markerMap[marker.id], "onDragEnd", marker.position.toJson())
      }
    })

    map.setOnCameraChangeListener(object : AMap.OnCameraChangeListener {
      override fun onCameraChangeFinish(position: CameraPosition) {
        emit(id, "onCameraIdle", Arguments.createMap().apply {
          putMap("cameraPosition", position.toJson())
          putMap("latLngBounds", map.projection.visibleRegion.latLngBounds.toJson())
        })
      }

      override fun onCameraChange(position: CameraPosition) {
        emit(id, "onCameraMove", Arguments.createMap().apply {
          putMap("cameraPosition", position.toJson())
          putMap("latLngBounds", map.projection.visibleRegion.latLngBounds.toJson())
        })
      }
    })

    map.setOnMultiPointClickListener { item ->
      item.customerId.split("_").let {
        emit(
          it[0].toInt(),
          "onPress",
          Arguments.createMap().apply { putInt("index", it[1].toInt()) },
        )
      }
      false
    }

    map.setOnMyLocationChangeListener {
      if (it.time > 0) {
        emit(id, "onLocation", it.toJson())
      }
    }
  }


  fun emit(id: Int?, event: String, data: WritableMap = Arguments.createMap()) {
    @Suppress("Deprecation")
    id?.let { eventEmitter.receiveEvent(it, event, data) }
  }

  private fun dispatchEvent(markView: MarkerView?, event: String, data: WritableMap? = null) {
    // 新架构
    markView?.marker?.id?.let { markerId ->
      markerMap[markerId]?.receiveEvent(event, data)
    }

  }

  fun add(child: View) {
    if (child is Overlay) {
      child.add(map)
      if (child is qiuxiang.amap3d.map_view.MarkerView) {
        markerMap[child.marker?.id!!] = child
      }
      if (child is Polyline) {
        polylineMap[child.polyline?.id!!] = child
      }
    }
  }
  private fun isReadableMapEmpty(map: ReadableMap?): Boolean {
    if (map == null) return true
    val iterator = map.keySetIterator()
    return !iterator.hasNextKey()
  }

  private fun readRawResource(resourceName: String): ByteArray {
    val resources = context.resources
    val resId = resources.getIdentifier(resourceName, "raw", context.packageName)
   return try {
     resources.openRawResource(resId).use { inputStream ->
       ByteArray(inputStream.available()).also { buffer ->
         var bytesRead = 0
         while (bytesRead < buffer.size) {
           bytesRead += inputStream.read(buffer, bytesRead, buffer.size - bytesRead)
         }
       }
     }
    } catch (e: Resources.NotFoundException) {
      Log.e("ResourceReader", "Resource not found: $resId", e)
      byteArrayOf()
    } catch (e: IOException) {
      Log.e("ResourceReader", "Error reading resource: $resId", e)
      byteArrayOf()
    }
  }

  fun setCustomStyleOptions(options: ReadableMap) {
    val styleOptions = CustomMapStyleOptions()
    if(isReadableMapEmpty(options)) {
      styleOptions.setEnable(false)
    }else {
      val styleData = options.getMap("styleData")
      styleData?.let {
        val path = styleData.getString("uri")
        path?.let {
          if(path.contains("/")) {
            styleOptions.setStyleDataPath(path.toString())
          }else{
            val buffer = readRawResource(path)
            buffer.let { styleOptions.setStyleData(buffer) }
          }
        }

      }

      val styleExtraData = options.getMap("styleExtraData")
      styleExtraData?.let {
        val path = styleExtraData.getString("uri")
        path?.let {
          if(path.contains("/")) {
            styleOptions.setStyleExtraPath(path.toString())
          }else{
            val buffer = readRawResource(path)
            buffer.let { styleOptions.setStyleExtraData(buffer) }
          }
          
        }
      }

        val styleTextureData = options.getMap("styleTextureData")
        styleTextureData?.let {
          val path = styleTextureData.getString("uri")
          path?.let {
            if(path.contains("/")) {
              styleOptions.setStyleTexturePath(path.toString())
            }else{
              val buffer = readRawResource(path)
              buffer.let { styleOptions.setStyleTextureData(buffer) }
            }
          }
        }

          val styleId = options.getString("styleId")
          styleId?.let {
            styleOptions.setStyleId(styleId.toString())
          }

          styleOptions.setEnable(true)
        }
        map?.setCustomMapStyle(styleOptions)
  }

  fun setLocationImage (source: ReadableMap) {
    fetchImage(source) {
      image = it
      Handler(Looper.getMainLooper()).post {
        locationStyle.myLocationIcon(image)

        map?.myLocationStyle = locationStyle
      }
    }
  }

  fun remove(child: View) {
    if (child is Overlay) {
      child.remove()
      if (child is qiuxiang.amap3d.map_view.MarkerView) {
        markerMap.remove(child.marker?.id)
      }
      if (child is Polyline) {
        polylineMap.remove(child.polyline?.id)
      }
    }
  }

  private val animateCallback = object : AMap.CancelableCallback {
    override fun onCancel() {}
    override fun onFinish() {}
  }

  fun moveCamera(args: ReadableArray?) {
    val current = map.cameraPosition
    val position = args?.getMap(0)!!
    val target = position.getMap("target")?.toLatLng() ?: current.target
    val zoom = position.getFloat("zoom") ?: current.zoom
    val tilt = position.getFloat("tilt") ?: current.tilt
    val bearing = position.getFloat("bearing") ?: current.bearing
    val cameraUpdate = CameraUpdateFactory.newCameraPosition(
      CameraPosition(target, zoom, tilt, bearing)
    )
    val duration = args.getInt(1).toLong()
    if(duration > 0) {
      if(position.getFloat("tilt") != null || position.getFloat("bearing") != null) {
        map.animateCamera(cameraUpdate, duration, animateCallback)
      }else {
        map.animateCamera(CameraUpdateFactory.newLatLngZoom(target, zoom),animateCallback)
      }
    }else {
      map.moveCamera(cameraUpdate)
    }
  }

  fun setInitialCameraPosition(position: ReadableMap) {
    if (initialCameraPosition == null) {
      initialCameraPosition = position
      moveCamera(Arguments.createArray().apply {
        pushMap(Arguments.createMap().apply { merge(position) })
        pushInt(0)
      })
    }
  }

  fun call(args: ReadableArray?) {
    val id = args?.getDouble(0)!!
    when (args.getString(1)) {
      "getLatLng" -> callback(
        id,
        // @todo 暂时兼容 0.63
        @Suppress("UNNECESSARY_NOT_NULL_ASSERTION")
        map.projection.fromScreenLocation(args.getMap(2)!!.toPoint()).toJson()
      )
      "reload" -> {
        callback(id, Arguments.createMap())
      }
    }
  }

  private fun callback(id: Double, data: Any) {
    emit(this.id, "onCallback", Arguments.createMap().apply {
      putDouble("id", id)
      when (data) {
        is WritableMap -> putMap("data", data)
      }
    })
  }
}