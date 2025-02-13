package qiuxiang.amap3d.map_view;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amap.api.maps.AMap;
import com.amap.api.maps.AMapException;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.TextureMapView;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.MyLocationStyle;
import com.amap.api.navi.AMapNavi;
import com.amap.api.navi.AMapNaviView;
import com.amap.api.navi.AMapNaviViewOptions;
import com.amap.api.navi.AmapNaviPage;
import com.amap.api.navi.AmapNaviParams;
import com.amap.api.navi.AmapNaviType;
import com.amap.api.navi.AmapPageType;
import com.amap.api.navi.enums.BroadcastMode;
import com.amap.api.navi.enums.MapStyle;
import com.amap.api.navi.enums.NaviType;
import com.amap.api.navi.model.AMapCalcRouteResult;
import com.amap.api.navi.model.AMapNaviLocation;
import com.amap.api.navi.model.AMapNaviPath;
import com.amap.api.navi.model.NaviInfo;
import com.amap.api.navi.model.NaviLatLng;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.facebook.react.views.image.ReactImageView;

import java.util.Map;
import java.util.Objects;

import qiuxiang.amap3d.R;

public class DriveNaviView extends SimpleViewManager<AMapNaviView> {

    public static final String REACT_CLASS = "DriveNaviView";
    private ReactApplicationContext mCallerContext;

    protected AMapNaviView aMapNaviView;

    private AMap aMap; //地图实例

    public AMapNavi aMapNavi;
//    public DriveViewText(ReactApplicationContext reactContext) {
//        mCallerContext = reactContext;
//    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    public MyOwnNaviListener myOwnNaviListener = new MyOwnNaviListener() {
        @Override
        public void onNaviSetting() {
            WritableMap event = Arguments.createMap();
            event.putBoolean("success", false);
            mCallerContext.getJSModule(RCTEventEmitter.class).receiveEvent(aMapNaviView.getId(), "onMoreButtonClicked", event);
        }

        @Override
        public void onInitNaviFailure() {
            Toast.makeText(mCallerContext, "设置了未传运单号", Toast.LENGTH_SHORT).show();
        }


        @Override
        public boolean onNaviBackClick() {
            WritableMap event = Arguments.createMap();
            event.putBoolean("success", false);
            mCallerContext.getJSModule(RCTEventEmitter.class).receiveEvent(aMapNaviView.getId(), "onCloseButtonClicked", event);
            return false;
        }

        @Override
        public void onArriveDestination() {
            WritableMap event = Arguments.createMap();
            event.putBoolean("success", false);
            mCallerContext.getJSModule(RCTEventEmitter.class).receiveEvent(aMapNaviView.getId(), "onDidEndEmulatorNavi", event);
        }

        @Override
        public void onEndEmulatorNavi() {
            WritableMap event = Arguments.createMap();
            event.putBoolean("success", false);
            mCallerContext.getJSModule(RCTEventEmitter.class).receiveEvent(aMapNaviView.getId(), "onDidEndEmulatorNavi", event);
        }

        @Override
        public void onNaviInfoUpdate(NaviInfo naviInfo) {
            NaviInfo info = naviInfo;
            if (info != null) {
                WritableMap event = Arguments.createMap();
                int distance=info.getPathRetainDistance();
                int time=info.getPathRetainTime();
                int lightCount=info.getRouteRemainLightCount();
                event.putInt("distance",distance);
                event.putInt("time",time);
                event.putInt("lightCount",lightCount);
                mCallerContext.getJSModule(RCTEventEmitter.class).receiveEvent(aMapNaviView.getId(), "onNaviInfoUpdate", event);
            }

        }

        @Override
        public void onLocationChange(AMapNaviLocation aMapNaviLocation) {
//            AMapNaviLocation info = aMapNaviLocation;
            if (aMapNaviLocation != null) {
                WritableMap event = Arguments.createMap();
                double longitude=aMapNaviLocation.getCoord().getLongitude();
                double latitude=aMapNaviLocation.getCoord().getLatitude();
                Long time=aMapNaviLocation.getTime();
                event.putDouble("longitude",longitude);
                event.putDouble("latitude",latitude);
                event.putString("time",String.valueOf(time));
                mCallerContext.getJSModule(RCTEventEmitter.class).receiveEvent(aMapNaviView.getId(), "onLocationUpdate", event);
            }
        }


    };

    @Nullable
    @Override
    public Map<String, Object> getExportedCustomBubblingEventTypeConstants() {
        return MapBuilder.of(
                "onMoreButtonClicked",
                MapBuilder.of(
                        "phasedRegistrationNames",
                        MapBuilder.of("bubbled", "onMoreButtonClicked")
                ),
                "onCloseButtonClicked",
                MapBuilder.of(
                        "phasedRegistrationNames",
                        MapBuilder.of("bubbled", "onCloseButtonClicked")
                ),
                "onDidEndEmulatorNavi",
                MapBuilder.of(
                        "phasedRegistrationNames",
                        MapBuilder.of("bubbled", "onDidEndEmulatorNavi")
                ),
                "onNaviInfoUpdate",
                MapBuilder.of(
                        "phasedRegistrationNames",
                        MapBuilder.of("bubbled", "onNaviInfoUpdate")
                ),
                "onLocationUpdate",
                MapBuilder.of(
                        "phasedRegistrationNames",
                        MapBuilder.of("bubbled", "onLocationUpdate")
                )


        );
    }

    @NonNull
    @Override
    protected AMapNaviView createViewInstance(@NonNull ThemedReactContext reactContext) {


        mCallerContext = reactContext.getReactApplicationContext();
        aMapNaviView = new AMapNaviView(reactContext);

        aMapNaviView.onCreate(null);
        aMapNaviView.setAMapNaviViewListener(myOwnNaviListener);

        aMap = aMapNaviView.getMap();
        MyLocationStyle myLocationStyle = new MyLocationStyle();
        myLocationStyle.showMyLocation(false);
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATE);
        myLocationStyle.strokeWidth(0);
        aMap.setMyLocationStyle(myLocationStyle);
        aMap.setMyLocationEnabled(true);

        try {
            aMapNavi = AMapNavi.getInstance(mCallerContext);
        } catch (AMapException e) {
            throw new RuntimeException(e);
        }
        try {
            aMapNavi = AMapNavi.getInstance(reactContext.getReactApplicationContext());
//            aMapNavi.removeAMapNaviListener(new NavigationCustomView().myOwnNaviListener);
            aMapNavi.addAMapNaviListener(myOwnNaviListener);
        } catch (AMapException e) {
            throw new RuntimeException(e);
        }
        AMapNaviViewOptions options = aMapNaviView.getViewOptions();
        //关闭自动绘制路线（如果你想自行绘制路线的话，必须关闭！！！）
//        options.setLayoutVisible(false);
        options.setSettingMenuEnabled(true);
        options.setAutoLockCar(true);
        options.setLaneInfoShow(true);
        options.setSecondActionVisible(true);
        aMapNaviView.setViewOptions(options);
        //关闭自动绘制路线（如果你想自行绘制路线的话，必须关闭！！！）
        if (aMapNavi != null) {
            aMapNavi.setMultipleRouteNaviMode(true);
            aMapNavi.setUseInnerVoice(true, true);
        }
//        aMapNavi.startNavi(NaviType.GPS);


        return aMapNaviView;
    }

    @Override
    public void receiveCommand(@NonNull AMapNaviView root, String commandId, @Nullable ReadableArray args) {
        if (Objects.equals(commandId, "reFreshUserLocation")) {
            LatLng myLocation = aMap.getMyLocation() != null ?
                    new LatLng(aMap.getMyLocation().getLatitude(), aMap.getMyLocation().getLongitude()) :
                    new LatLng(0, 0); // 如果无法获取位置，默认(0,0)
            // 将地图移动到当前位置
            aMap.moveCamera(CameraUpdateFactory.newLatLngZoom(myLocation, 15));
        }
        if (Objects.equals(commandId, "stopNavi")) {
            aMapNavi.stopNavi();
            aMapNaviView.onDestroy();
        }
        if (Objects.equals(commandId, "backMapView")) {
            aMapNaviView.onDestroy();
        }

    }


    @ReactProp(name = "mapViewModeType")
    public void setViewMode(AMapNaviView view, int mapViewModeType) {
        AMapNaviViewOptions options = aMapNaviView.getViewOptions();
        if (mapViewModeType == 2) {
            options.setMapStyle(MapStyle.AUTO, "");
        } else if (mapViewModeType == 1) {
            options.setMapStyle(MapStyle.NIGHT, "");
        } else {
            options.setMapStyle(MapStyle.DAY, "");
        }
        view.setViewOptions(options);
    }

    @ReactProp(name = "broadcastType")
    public void setBroadcastMode(AMapNaviView view, int broadcastType) {
        if (!aMapNavi.getIsUseInnerVoice()) {
            aMapNavi.setUseInnerVoice(true, true);
        }
        if (broadcastType == 0) {
            aMapNavi.startSpeak();
            aMapNavi.setBroadcastMode(BroadcastMode.DETAIL);
        } else if (broadcastType == 1) {
            aMapNavi.startSpeak();
            aMapNavi.setBroadcastMode(BroadcastMode.CONCISE);
        } else {
            aMapNavi.stopSpeak();
        }
    }

    @ReactProp(name = "trackingMode")
    public void setAngleOfView(AMapNaviView view, int trackingMode) {
        if(trackingMode==1){
            view.setNaviMode(0);
        }
        else{
            view.setNaviMode(1);
        }
    }

    @ReactProp(name = "autoZoomMapLevel")
    public void setAutoZoomMapLevel(AMapNaviView view, boolean autoZoomMapLevel) {
        AMapNaviViewOptions options = aMapNaviView.getViewOptions();
        options.setAutoChangeZoom(autoZoomMapLevel);
        view.setViewOptions(options);
    }

}
