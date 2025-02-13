package qiuxiang.amap3d.map_view;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amap.api.maps.AMap;
import com.amap.api.maps.AMapException;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.TextureMapView;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.LatLngBounds;
import com.amap.api.maps.model.MyLocationStyle;
import com.amap.api.maps.model.Poi;
import com.amap.api.maps.model.Polyline;
import com.amap.api.navi.AMapNavi;
import com.amap.api.navi.AmapNaviPage;
import com.amap.api.navi.AmapNaviParams;
import com.amap.api.navi.AmapNaviType;
import com.amap.api.navi.AmapPageType;
import com.amap.api.navi.INaviInfoCallback;
import com.amap.api.navi.enums.NaviType;
import com.amap.api.navi.enums.PathPlanningStrategy;
import com.amap.api.navi.model.AMapCalcRouteResult;
import com.amap.api.navi.model.AMapNaviLocation;
import com.amap.api.navi.model.AMapNaviPath;
import com.amap.api.navi.model.NaviLatLng;
import com.amap.api.navi.model.NaviPoi;
import com.amap.api.navi.model.RouteOverlayOptions;
import com.amap.api.navi.view.RouteOverLay;
import com.amap.api.services.route.RouteSearch;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import kotlin.jvm.internal.Intrinsics;
import qiuxiang.amap3d.R;

public class NavigationCustomView extends SimpleViewManager<TextureMapView> {

    public static final String REACT_CLASS = "NavigationCustomView"; //原生视图名称
    private TextureMapView mapView; //地图显示实例
    private AMap aMap; //地图实例
    public HashMap<String, Object> startPoint = new HashMap();//起点集合

    public HashMap<String, Object> endPoint = new HashMap();//终点集合

    public ArrayList<HashMap<String, Object>> wayPoints = new ArrayList<HashMap<String, Object>>();//途径点集合
    private ReactApplicationContext reactContext2;
    public AMapNavi aMapNavi;
    private Map<Integer, AMapNaviPath> naviPaths;//路线集合
    private int[] routIds;//路线id集合
    private int strategy = 10;//规划路线策略

    public DriveNaviView driveNaviView;

    List<NaviLatLng> allPointList = new ArrayList<>();//所有点位集合

    ArrayList<RouteOverLay> mCustomRouteOverlays = new ArrayList<RouteOverLay>();

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    public INaviInfoCallback iNaviInfoCallback=new MyOwnNaviListener() {
        @Override
        public void onExitPage(int i) {
            calculateRoute();
        }
    };

    public MyOwnNaviListener myOwnNaviListener=new MyOwnNaviListener() {
        @Override
        public void onCalculateRouteSuccess(AMapCalcRouteResult aMapCalcRouteResult) {
            try {
                aMapNavi = AMapNavi.getInstance(reactContext2);
            } catch (AMapException e) {
                throw new RuntimeException(e);
            }
            routIds = aMapCalcRouteResult.getRouteid();
            WritableArray routes = Arguments.createArray();
            naviPaths = aMapNavi.getNaviPaths();
            for (int i = 0; i < routIds.length; i++) {
                AMapNaviPath aMapNaviPath = naviPaths.get(routIds[i]);
                allPointList.addAll(aMapNaviPath.getCoordList());
                WritableMap pathHash = Arguments.createMap();
                pathHash.putString("routeId", String.valueOf(i));
                pathHash.putInt("routeTime", aMapNaviPath.getAllTime());
                pathHash.putInt("routeLength", aMapNaviPath.getAllLength());
                pathHash.putInt("routeTrafficLightCount", aMapNaviPath.getTrafficLightCount());
                routes.pushMap(pathHash);
            }
            drawRoutes();
            WritableMap event = Arguments.createMap();
            event.putArray("routes", routes);
            reactContext2.getJSModule(RCTEventEmitter.class).receiveEvent(mapView.getId(), "onCalculateRouteSuccess", event);
        }

        @Override
        public void onNaviSetting(){
            Toast.makeText(reactContext2, "设置了未传运单号", Toast.LENGTH_SHORT).show();

        }
    };


    @Override
    protected TextureMapView createViewInstance(ThemedReactContext reactContext) {
        reactContext2 = reactContext.getReactApplicationContext();
        mapView = new TextureMapView(reactContext);
        mapView.onCreate(null);
        aMap = mapView.getMap();
        try {
            aMapNavi = AMapNavi.getInstance(reactContext.getReactApplicationContext());
        } catch (AMapException e) {
            throw new RuntimeException(e);
        }
        //关闭自动绘制路线（如果你想自行绘制路线的话，必须关闭！！！）
        if (aMapNavi != null) {
            aMapNavi.addAMapNaviListener(myOwnNaviListener);
            aMapNavi.setMultipleRouteNaviMode(true);
        }
        // // 启用定位蓝点
        MyLocationStyle myLocationStyle = new MyLocationStyle();
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATE);
        aMap.setMyLocationStyle(myLocationStyle);
        aMap.setMyLocationEnabled(true);
        return mapView;
    }

    @Nullable
    @Override
    public Map<String, Object> getExportedCustomBubblingEventTypeConstants() {
        return MapBuilder.of("onCalculateRouteSuccess", MapBuilder.of("phasedRegistrationNames", MapBuilder.of("bubbled", "onCalculateRouteSuccess")));
    }


    @Override
    public void receiveCommand(@NonNull TextureMapView root, String commandId, @Nullable ReadableArray args) {
        NavigationCustomView that = this;
        if (Objects.equals(commandId, "setStrategy")) {
            if (args != null) {
                this.strategy = args.getInt(0);
                this.calculateRoute();
            }
        }
        if (Objects.equals(commandId, "startGPSNavi")) {
            aMapNavi.setUseInnerVoice(true,true);
            aMapNavi.startNavi(NaviType.GPS);
        }
        if (Objects.equals(commandId, "reFreshUserLocation")) {
            LatLng myLocation = aMap.getMyLocation() != null ?
                    new LatLng(aMap.getMyLocation().getLatitude(), aMap.getMyLocation().getLongitude()) :
                    new LatLng(0, 0); // 如果无法获取位置，默认(0,0)
            // 将地图移动到当前位置
            aMap.moveCamera(CameraUpdateFactory.newLatLngZoom(myLocation, 15));
        }
    }


    // 销毁资源时调用
    @Override
    public void onDropViewInstance(TextureMapView view) {
        super.onDropViewInstance(view);
        if (mapView != null) {
            mapView.onDestroy();
        }
    }

    private void clearRouteOverLay() {
        for (RouteOverLay routeOverLay : mCustomRouteOverlays) {
            routeOverLay.destroy();
        }
        mCustomRouteOverlays.clear();
    }

    private void drawRoutes() {
        // 清除之前的绘制
        clearRouteOverLay();
        // 主路线自定义纹理
        Bitmap unknownTraffic = BitmapFactory.decodeResource(reactContext2.getResources(), R.drawable.custtexture_grey);
        Bitmap smoothTraffic = BitmapFactory.decodeResource(reactContext2.getResources(), R.drawable.custtexture_green);
        Bitmap slowTraffic = BitmapFactory.decodeResource(reactContext2.getResources(), R.drawable.custtexture_slow);
        Bitmap jamTraffic = BitmapFactory.decodeResource(reactContext2.getResources(), R.drawable.custtexture_bad);
        Bitmap veryJamTraffic = BitmapFactory.decodeResource(reactContext2.getResources(), R.drawable.custtexture_serious);
        // 备选路线自定义纹理
        Bitmap unSelectedUnknownTraffic = BitmapFactory.decodeResource(reactContext2.getResources(), R.drawable.custtexture_grey);

        // 绘制主路线
        RouteOverLay mainRouteOverlay = new RouteOverLay(mapView.getMap(), aMapNavi.getNaviPath(), reactContext2);
        RouteOverlayOptions options = new RouteOverlayOptions();
        options.setUnknownTraffic(unknownTraffic);
        options.setSmoothTraffic(smoothTraffic);
        options.setSlowTraffic(slowTraffic);
        options.setJamTraffic(jamTraffic);
        options.setVeryJamTraffic(veryJamTraffic);
        options.setLineWidth(60);
        mainRouteOverlay.setRouteOverlayOptions(options);
        mainRouteOverlay.addToMap();
        mainRouteOverlay.setLightsVisible(false);
        mCustomRouteOverlays.add(mainRouteOverlay);

        // 绘制备选路线
        for (AMapNaviPath path : aMapNavi.getNaviPaths().values()) {
            if (path.getPathid() == aMapNavi.getNaviPath().getPathid()) {
                continue;
            }
            RouteOverLay backupRoute = new RouteOverLay(mapView.getMap(), path, reactContext2);
            RouteOverlayOptions option = new RouteOverlayOptions();
            option.setUnknownTraffic(unSelectedUnknownTraffic);
            option.setSmoothTraffic(unSelectedUnknownTraffic);
            option.setSlowTraffic(unSelectedUnknownTraffic);
            option.setJamTraffic(unSelectedUnknownTraffic);
            option.setVeryJamTraffic(unSelectedUnknownTraffic);
            option.setLineWidth(50);
            backupRoute.setRouteOverlayOptions(option);
            backupRoute.setZindex(-1);
            backupRoute.showStartMarker(false);
            backupRoute.showEndMarker(false);
            backupRoute.addToMap();
            backupRoute.setLightsVisible(false);
            mCustomRouteOverlays.add(backupRoute);
        }
        //自动调整地图比例
        zoomToSpan();
    }

    // React Native 方法用于规划路线
    public void calculateRoute() {
        aMapNavi=null;
        try {
            aMapNavi = AMapNavi.getInstance(reactContext2);
        } catch (AMapException e) {
            throw new RuntimeException(e);
        }
        String startName = (String) this.startPoint.get("name");
        HashMap startPosition = (HashMap) this.startPoint.get("position");
        String endName = (String) this.endPoint.get("name");
        HashMap endNamePosition = (HashMap) this.endPoint.get("position");
        NaviPoi start = new NaviPoi(startName, new LatLng((Double) startPosition.get("latitude"), (Double) startPosition.get("longitude")), "");
        NaviPoi end = new NaviPoi(endName, new LatLng((Double) endNamePosition.get("latitude"), (Double) endNamePosition.get("longitude")), "");
        // 途经点信息
        List<NaviPoi> waysPoiIds = new ArrayList<NaviPoi>();
        for (HashMap<String, Object> point : this.wayPoints) {
            String name = (String) point.get("name");
            HashMap pointPosition = (HashMap) point.get("position");
            waysPoiIds.add(new NaviPoi(name, new LatLng((Double) pointPosition.get("latitude"), (Double) pointPosition.get("longitude")), ""));
        }
        aMapNavi.addAMapNaviListener(myOwnNaviListener);
        aMapNavi.calculateDriveRoute(start, end, waysPoiIds, this.strategy);
    }


    @ReactProp(name = "points")
    public void setPoint(TextureMapView view, @Nullable ReadableMap points) {
        if (points == null) return;
        ReadableMap startPoint = points.getMap("startPoint");
        ReadableMap endPoint = points.getMap("endPoint");
        ReadableArray wayPoints = points.getArray("wayPoints");
        if (startPoint == null || endPoint == null) return;
        //起点-终点
        this.startPoint = startPoint.toHashMap();
        this.endPoint = endPoint.toHashMap();
        this.wayPoints.clear();
        //途径点
        if (wayPoints != null && wayPoints.size() > 0) {
            for (int i = 0; i < wayPoints.size(); i++) {
                ReadableMap point = wayPoints.getMap(i);
                this.wayPoints.add(point.toHashMap());
            }
        }
        //终点
        this.calculateRoute();
    }

    @ReactProp(name = "routeID")
    public void setRouteId(TextureMapView view, @Nullable Integer routeID) {
        if (routeID == null || routIds == null || routIds.length == 0) return;
        int realRouteId = routIds[routeID];
        aMapNavi.selectRouteId(realRouteId);
        AMapNaviPath path = aMapNavi.getNaviPath();
        if(path==null) {
            Toast.makeText(reactContext2, "路径规划失败", Toast.LENGTH_SHORT).show();
            return;
        };
        Map<Integer, AMapNaviPath> paths = aMapNavi.getNaviPaths();
        long mainPathId = path.getPathid();
        drawRoutes();
    }


    // React Native 生命周期回调
    @ReactMethod
    public void onResume() {
        if (mapView != null) {
            mapView.onResume();
        }
    }

    @ReactMethod
    public void onPause() {
        if (mapView != null) {
            mapView.onPause();
        }
    }

    @ReactMethod
    public void onDestroy() {
        if (mapView != null) {
            mapView.onDestroy();
        }
    }

    public void zoomToSpan() {
        if (this.allPointList != null && this.allPointList.size() > 0) {
            if (aMap == null) return;
//            centerMarker.setVisible(false);
            LatLngBounds bounds = getLatLngBounds(this.allPointList);
            aMap.moveCamera(CameraUpdateFactory.newLatLngBounds(bounds, 50));
        }
    }

    private LatLngBounds getLatLngBounds(List<NaviLatLng> pointList) {
        LatLngBounds.Builder b = LatLngBounds.builder();
        for (int i = 0; i < pointList.size(); i++) {
            LatLng p = new LatLng(pointList.get(i).getLatitude(), pointList.get(i).getLongitude());
            b.include(p);
        }
        return b.build();
    }


}

