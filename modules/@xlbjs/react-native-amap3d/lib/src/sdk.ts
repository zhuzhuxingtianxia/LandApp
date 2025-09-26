import { LatLng } from "@xlbjs/react-native-amap3d/lib/src/types";
import { NativeEventEmitter, NativeModules, Platform } from "react-native";

const {
  AMapSdk,
  NavigationManager,
  AMapSdkJavaVersion,
  NavigationComponent,
  NavigationCustomView,
  TrackModuleManager,
} = NativeModules;

export interface PlaceQuery {
  keyword?: string;
  // 类型，多个类型用“|”分割 可选值:文本分类、分类代码
  type?: string;
  cityCode?: string;
  pageSize?: number;
  pageNum?: number;
  around?: number;
  lon?: number;
  lat?: number;
}

export interface NavigationConfig {
  type: number;
  lon: number;
  lat: number;
  name: string;
  POIId?: string;
}

export function init(apiKey?: string) {
  AMapSdk.initSDK(apiKey);
}

export function getVersion(): Promise<string> {
  return AMapSdk.getVersion();
}
/**
 * @brief 判断经纬度点是否在圆内
 * @param point  经纬度
 * @param center 圆的中心经纬度
 * @param radius 圆的半径，单位米
 * @return 判断结果
 */
export function MACircleContainsCoordinate(point: LatLng,center: LatLng, radius: number): Promise<any> {
  if (Platform.OS == "ios") {
    return NavigationCustomView?.MACircleContainsCoordinate(point, center, radius);
  } else {
    return AMapSdkJavaVersion?.circleContainsCoordinate(point, center, radius);
  }
}
/**
 * @brief 将坐标转成高德坐标
 * @param point  经纬度
 * type=>坐标类型枚举
 * -1:AMap ;
 * 0:Baidu;
 * 1:MapBar;
 * 2:MapABC;
 * 3:SoSoMap;
 * 4:AliYun;
 * 5:Google;
 * 6:GPS
 * @param type
 * @return 高德坐标
 */
export function AMapCoordinateConvert(point: LatLng, type: number = 6): Promise<any> {
  try {
    if (Platform.OS == "ios") {
      return NavigationCustomView?.AMapCoordinateConvert(point, type);
    }else {
      return AMapSdkJavaVersion?.AMapCoordinateConvert(point, type);
    }
  } catch (error) {
    return Promise.reject(error);
  }
  
}

/**
 * @description 两点间直线距离计算
*/
export function calculateLineDistance(start: LatLng, end: LatLng): Promise<number> {
  try {
    if (Platform.OS == "ios") {
      return NavigationCustomView.calculateLineDistance(start, end);
    } else {
      return AMapSdkJavaVersion.calculateLineDistance(start, end);
    }
  } catch (error) {
    return Promise.reject(error);
  }
  
}

/**
 * @description 两点间面积计算
 * @param leftTopLatlng 
 * @param rightBottomLatlng 
 * @returns 
 */
export function calculateArea(leftTopLatlng: LatLng, rightBottomLatlng: LatLng): Promise<number> {
  return NavigationCustomView?.calculateArea(leftTopLatlng, rightBottomLatlng);
}
/**
 * @description 用于路径规划距离测量
 * @param latLonPoints 起点支持多个
 * @param dest 终点
 * @param type 0:直线距离 1:驾车距离
*/
export function distanceSearch(latLonPoints: LatLng[],dest: LatLng, type: number): Promise<number> {
  return NavigationCustomView?.distanceSearch(latLonPoints, dest, type);
  
}

/**
 * @description 搜索查询
 * @param { keyword, type, cityCode } poiSearch
 * @param { lon, lat, keyword, around, type } nearbySearch
 * @returns
*/
export function positionQuery(params: PlaceQuery): Promise<string> {
  const { keyword, type, cityCode, pageSize, pageNum, around, lon, lat } = params;
  // kotlin 原生接受数字类型报错，先转成字符串
  const paramsStr = {
    keyword,
    type,
    cityCode,
    pageSize: pageSize ? `${pageSize}` : undefined,
    pageNum: pageNum ? `${pageNum}` : undefined,
    around: around ? `${around}` : undefined,
    lon: lon ? `${lon}` : undefined,
    lat: lat ? `${lat}` : undefined,
  }
  return AMapSdk.poiSearch(paramsStr);
  // return AMapSdk.poiSearch(params)
}
/** 获取位置信息
 * @param hasReGeocode 是否需要逆地理编码
 * @returns
 */
export function getLocation(hasReGeocode: boolean = true): Promise<string> {
  return AMapSdk.getLocation(hasReGeocode);
}

/**
 * @description 获取系统定位位置信息，不使用高德SDK接口。可用于获取城市信息
 * @returns
*/
export function getSystemLocation(): Promise<string> {
  return AMapSdk.getSystemLocation();
}

/** 根据经纬度拿地址
 * @param longitude
 * @param latitude
 * @returns
 */
export function reverseGeocode(longitude: number, latitude: number): Promise<string> {
  return AMapSdk.reverseGeocode({ longitude, latitude });
}

/**导航sdk */
//开始GPS导航
export function startGPSNavi() {
  NavigationCustomView?.startGPSNavi?.();
}

//停止GPS导航
export function stopNavi() {
  if (Platform.OS == "ios") {
    NavigationCustomView?.stopNavi?.();
  } else {
    AMapSdkJavaVersion?.stopNavi();
  }
}

//刷新路线
export function reFreshNaviRout(type: number) {
  NavigationCustomView?.reFreshNaviRout?.(type);
}
//定位到用户蓝点
export function reFreshUserLocation() {
  NavigationCustomView?.reFreshUserLocation?.();
}

/**猎鹰sdk */
//初始化猎鹰sdk
export function initTrackManager(serviceID: string, terminalID: string): Promise<any> {
  return TrackModuleManager?.initTrackManager?.(serviceID, terminalID);
}

//开启位置上传
export function startGatherAndPack(trackID: string): Promise<any> {
  return TrackModuleManager?.startGatherAndPack?.(trackID);
}

//关闭位置上传
export function stopGaterAndPack() {
  TrackModuleManager?.stopGaterAndPack?.();
}

/** 猎鹰开启定位上传的监听 */
// onStartGatherAndPackSuccess 采集成功
// onStartGatherAndPackFailure 采集失败
export const TrackModuleManagerEmitter = new NativeEventEmitter(TrackModuleManager);
