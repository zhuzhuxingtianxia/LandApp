package qiuxiang.amap3d.modules

import android.util.Log
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.amap.api.maps.MapsInitializer
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.core.PoiItemV2
import com.amap.api.services.geocoder.GeocodeSearch
import com.amap.api.services.geocoder.RegeocodeAddress
import com.amap.api.services.geocoder.RegeocodeQuery
import com.amap.api.services.geocoder.RegeocodeResult
import com.amap.api.services.poisearch.PoiResultV2
import com.amap.api.services.poisearch.PoiSearchV2
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.google.gson.Gson


 class RegecodeResult  {
    var country : String = ""
    var province : String = ""
    var city : String = ""
    var formattedAddress : String = ""
    var district : String = ""
    var citycode : String = ""
    var adcode : String = ""
    var street : String = ""
    var number : String = ""
    var poiName : String = ""
    var aoiName : String = ""

    constructor(data: RegeocodeAddress?) {
         country = data?.country ?: ""
         province = data?.province ?: ""
         city = data?.city ?: ""
         formattedAddress = data?.formatAddress ?: ""
         district = data?.district ?: ""
         citycode = data?.cityCode ?: ""
         adcode = data?.adCode ?: ""
         street = data?.streetNumber?.street.toString()
         number = data?.streetNumber?.number.toString()
        if (data?.pois?.isEmpty() ?: true) {
            poiName = ""
        } else {
            val poi =  data?.pois?.first()
            poiName = poi?.title.toString()
        }

        if (data?.aois?.isEmpty() ?: true) {
            aoiName = ""

        } else {
            val aoi = data?.aois?.first()
            aoiName = aoi?.aoiName.toString()
        }



    }

}


class MapLocation(private val promise: Promise) : AMapLocationListener {
    override fun onLocationChanged(p0: AMapLocation?) {
        try {
            if (p0 != null) {
                Log.d("MapLocation", p0.toString())
                val mutableMap = mutableMapOf<String, Any>(
                    "locationType" to p0.locationType,
                    "latitude" to p0.latitude,
                    "longitude" to p0.longitude,
                    "cood" to mapOf(
                        "latitude" to p0.latitude,
                        "longitude" to p0.longitude,
                    ),
                    "regeocode" to mapOf(
                        "country" to p0.country,
                        "province" to p0.province,
                        "city" to p0.city,
                        "formattedAddress" to p0.address,
                        "district" to p0.district,
                        "citycode" to p0.cityCode,
                        "adcode" to p0.adCode,
                        "street" to p0.street,
                        "number" to p0.streetNum,
                        "poiName" to p0.poiName,
                        "aoiName" to p0.aoiName,
                    ),
                )
                val json = Gson();
                promise.resolve(json.toJson(mutableMap))
            } else {
                promise.resolve(null)
            }
        } catch (err: Exception) {
            promise.reject("error on location opreation")
        }

    }
}


class GecodeListener( private val promise: Promise) : GeocodeSearch.OnGeocodeSearchListener {


    override fun onRegeocodeSearched(result: RegeocodeResult?, rCode: Int) {
        if (rCode == 1000 && result != null) { // Success code
            try {
                val regecodeAddress = result.regeocodeAddress

                val info = RegecodeResult(regecodeAddress)


                val infoStr = Gson().toJson(info)
                promise.resolve(infoStr)
            } catch (
                    err: Exception
            ) {
                promise.reject("err opreation", "regecode error: $err")
            }


        } else {
            promise.reject("GEOCODING_ERROR", "Error occurred: $rCode")
        }
    }

    override fun onGeocodeSearched(result: com.amap.api.services.geocoder.GeocodeResult?, rCode: Int) {
        // Not used for reverse geocoding
    }
}

@Suppress("unused")
class SdkModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    private val context: ReactApplicationContext = reactContext
    
    override fun getName(): String {
        return "AMapSdk"
    }

    @ReactMethod
    fun initSDK(apiKey: String?) {
        apiKey?.let {
            MapsInitializer.setApiKey(it)
            MapsInitializer.updatePrivacyAgree(context, true)
            MapsInitializer.updatePrivacyShow(context, true, true)
            AMapLocationClient.updatePrivacyAgree(context, true)
            AMapLocationClient.updatePrivacyShow(context, true, true)
        }
    }

    @ReactMethod
    fun getVersion(promise: Promise) {
        promise.resolve(MapsInitializer.getVersion())
    }

    @ReactMethod
    fun getConsole(promise: Promise) {
        // println("Hello Kotlin/Native!")
        promise.resolve(5)
    }

    @ReactMethod
    fun reverseGeocode(point: ReadableMap, promise: Promise) {
        if (point == null) {
            promise.reject("INVALID_ARGUMENT, Latitude and Longitude are required")
            return
        }
        // println("Hello Kotlin/Native!")
        val latLonPoint = LatLonPoint(point.getDouble("latitude"), point.getDouble("longitude"))
        val query = RegeocodeQuery(latLonPoint, 100f, GeocodeSearch.AMAP)
        val gecodeListener = GecodeListener( promise)
         val geocodeSearch = GeocodeSearch(context)

        geocodeSearch.setOnGeocodeSearchListener(gecodeListener)
        geocodeSearch.getFromLocationAsyn(query)

    }


    @ReactMethod
    fun poiSearch(params: ReadableMap, promise: Promise) {
        val keyword = if (params.hasKey("keyword")) params.getString("keyword") else null
        val type = if (params.hasKey("type")) params.getString("type") else null
        val cityCode = if (params.hasKey("cityCode")) params.getString("cityCode") else null
        val pageSize = if (params.hasKey("pageSize")) params.getString("pageSize") else null
        val pageNum = if (params.hasKey("pageNum")) params.getString("pageNum") else null
        val around = if (params.hasKey("around")) params.getString("around") else null
        val lon = if (params.hasKey("lon")) params.getString("lon") else null
        val lat = if (params.hasKey("lat")) params.getString("lat") else null
        try {
            val pageSizeCount = if (pageSize == null) 0 else pageSize!!.toInt()
            val pageNumCount = if(pageNum == null) 0 else pageNum!!.toInt()
            val aroundNum = if (around == null) 1000 else around!!.toInt()
            val codeType = if (type == null) "" else type!!
            val cityCodeStr = if (cityCode == null) "" else  cityCode!!

            val  query =  PoiSearchV2.Query(keyword, codeType, cityCodeStr)
            query.pageSize = pageSizeCount
            query.pageNum = pageNumCount

            val poiSearchInstance = PoiSearchV2(context, query)

            if (lon != null && lat != null ) {
                // promise.reject("11111, error")
                val longitude = lon!!.toDouble()
                val latitude = lat!!.toDouble()
                val pointCenter = LatLonPoint(latitude!!, longitude!!)
                poiSearchInstance.bound = PoiSearchV2.SearchBound(pointCenter, aroundNum)
            }

            poiSearchInstance.setOnPoiSearchListener(object: PoiSearchV2.OnPoiSearchListener {
                override fun onPoiItemSearched(p0: PoiItemV2?, p1: Int) {

                }

                override fun onPoiSearched(p0: PoiResultV2?, p1: Int) {
                    if (p1 == 1000) {
                        if (p0 != null && p0.query != null) {
                            val posResult = p0
                            val poiItems = posResult.pois
                            if (poiItems != null ) {
                                val jsonArry = mutableListOf<Any>()
                                for (item in poiItems) {
                                    val poi = mapOf(
                                        "name" to item.title,
                                        "code" to item.adCode,
                                        "address" to item.snippet,
                                        "latitude" to item.latLonPoint.latitude,
                                        "longitude" to item.latLonPoint.longitude,
                                        "province" to item.provinceName,
                                        "city" to item.cityName,
                                        "county" to item.adName,
                                    )
                                    jsonArry.add(poi)
                                }
                                val responseStr = Gson().toJson(jsonArry)

                                promise.resolve(responseStr)
                            }else {
                                promise.reject("search error")
                            }
                        }

                    } else if (p1 == 27) {
                        promise.reject("network error")
                    } else if (p1 == 32) {
                        promise.reject(" error keyword")
                    } else {
                        promise.reject("unexpect error, errCode:"  + p1)
                    }
                }
            })
            poiSearchInstance.searchPOIAsyn()

        } catch (e: Exception) {
            promise.reject("error in JDK")
        }
    }

    @ReactMethod
    fun getSystemLocation(promise: Promise) {
        promise.resolve("")
    }

    @ReactMethod
    fun getLocation(hasReGeocode: Boolean, promsie: Promise) {
        try {
            var locationClient: AMapLocationClient? = null
            val locationListener: AMapLocationListener = MapLocation(promsie)
            locationClient = AMapLocationClient(context)
            locationClient.setLocationListener(locationListener)
            val mLocationOption = AMapLocationClientOption()
            mLocationOption.locationPurpose = AMapLocationClientOption.AMapLocationPurpose.SignIn
            mLocationOption.locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
            mLocationOption.isOnceLocation = true
            mLocationOption.isNeedAddress = hasReGeocode
            mLocationOption.isMockEnable = true
            mLocationOption.isLocationCacheEnable = true
            if (locationClient != null) {
                locationClient.setLocationOption(mLocationOption)
                locationClient.stopLocation()
                locationClient.startLocation()
            }


        } catch (err: Exception) {
            promsie.reject("something error on get location")
        }
    }
}
