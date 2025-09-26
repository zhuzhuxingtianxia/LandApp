import { ImageRequireSource, ImageURISource } from "react-native";

/**
 * 点坐标
 */
export interface Point {
  x: number;
  y: number;
}

/**
 * 地理坐标
 */
export interface LatLng {
  /**
   * 纬度
   */
  latitude: number;

  /**
   * 经度
   */
  longitude: number;
}

/**
 * 地图标注点
 */
export interface  MapPoi {
  /**
   * 标注点 ID
   */
  id?: string;

  /**
   * 标注点名称
   */
  name: string;
  /**
   * 标注点坐标
   */
  position: LatLng;
}

/**
 * 导航路径点位
 */
export interface NavigationPoints {
  startPoint:MapPoi,
  wayPoints?: MapPoi[];
  endPoint: MapPoi;
}
/**
 * 地图标注点类型
 */
export enum MapPoiType {
  /**
   * 起点
   */
  start,

  /**
   * 终点
   */
  end,

  /**
   * 途经点
   */
  way
}
/**
 * 矩形坐标边界
 */
export interface LatLngBounds {
  /**
   * 西南坐标
   */
  southwest: LatLng;

  /**
   * 东北坐标
   */
  northeast: LatLng;
}

/**
 * 地图状态
 */
export interface CameraPosition {
  /**
   * 中心坐标
   */
  target?: LatLng;

  /**
   * 缩放级别
   */
  zoom?: number;

  /**
   * 朝向、旋转角度[0-360]
   */
  bearing?: number;

  /**
   * 倾斜角度[0-45]
   */
  tilt?: number;
}

/**
 * 定位
 */
export interface Location extends LatLng {
  /**
   * 精度
   */
  accuracy: number;

  /**
   * 朝向
   */
  heading: number;

  /**
   * 海拔
   */
  altitude: number;

  /**
   * 运动速度
   */
  speed: number;
}

export interface GeolocationPosition {
  coords: Location;
  timestamp: number;
}

export type MapRequireSource = ImageRequireSource | ImageURISource;
export interface MapCustomStyleOptions {
  /**
   * @description 自定义样式base64或二进制数据
   */
  styleData?: MapRequireSource;
  /**
   * @description 样式额外的配置，比如路况，背景颜色等, 数据类型base64或二进制数据
   */
  styleExtraData?: MapRequireSource;
  /**
   * @description 纹理，需付费
  */
  styleTextureData?: MapRequireSource;
  /**
   * @description 设置地图自定义样式对应的styleID，从官网获取
   */
  styleId?: string;
  /**
   * @description 海外自定义样式文件路径
   */
  styleDataOverseaPath?: string;
}

/**
 * 地图类型
 */
export enum MapType {
  /**
   * 标准地图
   */
  Standard,

  /**
   * 卫星地图
   */
  Satellite,

  /**
   * 夜间地图
   */
  Night,

  /**
   * 导航地图
   */
  Navi,

  /**
   * 公交地图
   */
  Bus,
}


/**
 * 地图类型
 */
export enum NaviDrivingStrategy {
  AMapNaviDrivingStrategySingleDefault = 0,                               ///< 0 单路径: 默认,速度优先(常规最快)
  AMapNaviDrivingStrategySingleAvoidCost = 1,                             ///< 1 单路径: 避免收费
  AMapNaviDrivingStrategySinglePrioritiseDistance = 2,                    ///< 2 单路径: 距离优先
  AMapNaviDrivingStrategySingleAvoidExpressway = 3,                       ///< 3 单路径: 不走快速路
  AMapNaviDrivingStrategySingleAvoidCongestion = 4,                       ///< 4 单路径: 躲避拥堵
  AMapNaviDrivingStrategySinglePrioritiseSpeedCostDistance = 5,           ///< 5 单路径: 速度优先 & 费用优先 & 距离优先
  AMapNaviDrivingStrategySingleAvoidHighway = 6,                          ///< 6 单路径: 不走高速
  AMapNaviDrivingStrategySingleAvoidHighwayAndCost = 7,                   ///< 7 单路径: 不走高速 & 避免收费
  AMapNaviDrivingStrategySingleAvoidCostAndCongestion = 8,                ///< 8 单路径: 避免收费 & 躲避拥堵
  AMapNaviDrivingStrategySingleAvoidHighwayAndCostAndCongestion = 9,      ///< 9 单路径: 不走高速 & 避免收费 & 躲避拥堵
}
///导航界面中的地图样式类型 since 6.7.0

export enum NaviViewMapModeType {
   NaviViewMapModeTypeDay = 0,                ///< 白天模式
   NaviViewMapModeTypeNight = 1,              ///< 黑夜模式
   NaviViewMapModeTypeDayNightAuto = 2,       ///< 根据日出日落时间自动切换白天黑夜
   NaviViewMapModeTypeCustom = 3,             ///< 自定义地图样式 (还需传入 MAMapCustomStyleOptions )
};

///导航界面跟随模式
export enum NaviViewTrackingMode {
    NaviViewTrackingModeMapNorth = 0,      ///< 0 正北朝上
    NaviViewTrackingModeCarNorth,          ///< 1 车头朝上
};

///导航组件中的语音播报类型 since 7.1.0
export enum NaviCompositeBroadcastType 
 {
   NaviCompositeBroadcastDetailed = 0,         ///< 详细播报
   NaviCompositeBroadcastConcise  = 1,         ///< 简洁播报
   NaviCompositeBroadcastMute     = 2,         ///< 静音
};