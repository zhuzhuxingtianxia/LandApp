package qiuxiang.amap3d.map_view;

import android.content.Intent;
import android.os.Build;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.maps.AMapException;
import com.amap.api.maps.AMapUtils;
import com.amap.api.maps.CoordinateConverter;
import com.amap.api.maps.MapsInitializer;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.Poi;
import com.amap.api.navi.AMapNavi;
import com.amap.api.navi.AmapNaviPage;
import com.amap.api.navi.AmapNaviParams;
import com.amap.api.navi.AmapNaviType;
import com.amap.api.navi.AmapPageType;
import com.amap.api.navi.enums.NaviType;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableMap;

import java.util.HashMap;

public class AMapSdkJavaVersion extends ReactContextBaseJavaModule {
    private ReactApplicationContext reactContext2;
    public AMapNavi aMapNavi;

    private AMapLocationClient mLocationClient;

    public AMapSdkJavaVersion(ReactApplicationContext context) {
        super(context);
        reactContext2 = context;

    }

    @ReactMethod
    public void init() {

        // MapsInitiinitalizer.setApiKey(key);
        // MapsInitializer.updatePrivacyAgree(reactContext2, true);
        // MapsInitializer.updatePrivacyShow(reactContext2, true, true);
        // AMapLocationClient.updatePrivacyAgree(reactContext2, true);
        // AMapLocationClient.updatePrivacyShow(reactContext2, true, true);
        try {
            aMapNavi = AMapNavi.getInstance(reactContext2);
        } catch (AMapException e) {
            throw new RuntimeException(e);
        }
    }

    @NonNull
    @Override
    public String getName() {
        return "AMapSdkJavaVersion";
    }

    @ReactMethod
    public void AMapCoordinateConvert(ReadableMap point, Integer type, Promise promise) {
        CoordinateConverter converter  = new CoordinateConverter(reactContext2);
        // CoordType.GPS 待转换坐标类型
        CoordinateConverter.CoordType coordType = CoordinateConverter.CoordType.GPS;
        if(type == 0) {
            coordType = CoordinateConverter.CoordType.BAIDU;
        }else if(type == 1) {
            coordType = CoordinateConverter.CoordType.MAPBAR;
        }else if(type == 2) {
            coordType = CoordinateConverter.CoordType.MAPABC;
        }else if(type == 3) {
            coordType = CoordinateConverter.CoordType.SOSOMAP;
        }else if(type == 4) {
            coordType = CoordinateConverter.CoordType.ALIYUN;
        }else if(type == 5) {
            coordType = CoordinateConverter.CoordType.GOOGLE;
        }
        converter.from(coordType);
        // sourceLatLng待转换坐标点 LatLng类型
        LatLng pointData = new LatLng((Double) point.getDouble("latitude"), (Double) point.getDouble("longitude"));
        converter.coord(pointData);
        // 执行转换操作
        LatLng desLatLng = converter.convert();
        WritableMap event = Arguments.createMap();
        event.putDouble("latitude", desLatLng.latitude);
        event.putDouble("longitude", desLatLng.longitude);
        promise.resolve(event);
    }
    @ReactMethod
    public void circleContainsCoordinate(ReadableMap point, ReadableMap center, int radius, Promise promise) {
        if (point == null || center == null) {
            promise.resolve(false);
            return;
        }
        LatLng pointData = new LatLng((Double) point.getDouble("latitude"), (Double) point.getDouble("longitude"));
        LatLng centerData = new LatLng((Double) center.getDouble("latitude"), (Double) center.getDouble("longitude"));
        float distance = AMapUtils.calculateLineDistance(pointData, centerData);
        promise.resolve(radius > distance);
    }

    // 两点间直线距离计算
    @ReactMethod
    public void calculateLineDistance(ReadableMap start, ReadableMap end, Promise promise) {
        if (start == null || end == null) {
            promise.reject("参数有误");
            return;
        }
        LatLng pointData = new LatLng((Double) start.getDouble("latitude"), (Double) start.getDouble("longitude"));
        LatLng centerData = new LatLng((Double) end.getDouble("latitude"), (Double) end.getDouble("longitude"));
        float distance = AMapUtils.calculateLineDistance(pointData, centerData);
        promise.resolve(distance);
    }

    @ReactMethod
    public void stopNavi() {
        try {
            aMapNavi = AMapNavi.getInstance(reactContext2);
        } catch (AMapException e) {
            throw new RuntimeException(e);
        }
        aMapNavi.stopNavi();
    }

    @ReactMethod
    public void getCurrentLocation(Promise promise) {
        try {
            mLocationClient = new AMapLocationClient(reactContext2);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        AMapLocationClientOption mLocationOption = new AMapLocationClientOption();
        mLocationOption.setOnceLocation(true);
        mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);

        mLocationClient.setLocationOption(mLocationOption);

        mLocationClient.setLocationListener(new AMapLocationListener() {
            @Override
            public void onLocationChanged(AMapLocation amapLocation) {
                if (amapLocation != null) {
                    if (amapLocation.getErrorCode() == 0) {
                        // 定位成功，返回位置信息
                        promise.resolve(amapLocation.getLongitude() + "," + amapLocation.getLatitude());
                    } else {
                        // 定位失败
                        promise.reject("AMAP_ERROR", "Location Error, ErrCode:"
                                + amapLocation.getErrorCode() + ", errInfo:"
                                + amapLocation.getErrorInfo());
                    }
                    mLocationClient.stopLocation();
                }
            }
        });

        mLocationClient.startLocation();

    }

    @ReactMethod
    public void startLocationService(ReadableMap obj) {
        ReadableNativeMap newMap = (ReadableNativeMap) obj;
        HashMap locationObj = newMap.toHashMap();
        if (!obj.hasKey("sid")) {
            return;
        }

        if (!obj.hasKey("tid")) {
            return;
        }
        if (!obj.hasKey("trid")) {
            return;
        }
        Intent intent = new Intent(reactContext2, LocationService.class);
        intent.putExtra("sid", (String) locationObj.get("sid"));
        intent.putExtra("tid", (String) locationObj.get("tid"));
        intent.putExtra("trid", (String) locationObj.get("trid"));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            reactContext2.startForegroundService(intent);

        } else {
            reactContext2.startService(intent);
        }
    }

    @ReactMethod
    public void stopLocationService() {
        Intent serviceIntent = new Intent(reactContext2, LocationService.class);
        reactContext2.stopService(serviceIntent);
    }
}
