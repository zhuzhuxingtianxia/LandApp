import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { HostComponent, NativeSyntheticEvent, ViewProps } from 'react-native';
import type { BubblingEventHandler, Float, Int32, WithDefault } from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import type { ImageSource } from 'react-native/Libraries/Image/Image.types';
import type React from 'react';
import type {
  Double,
} from 'react-native/Libraries/Types/CodegenTypes';

interface LatLng {
  latitude: Double;
  longitude: Double;
}

interface Point {
  x: Double;
  y: Double;
}


export interface NativeProps extends ViewProps {
  /**
   * 坐标
   */
  position: LatLng;

  /**
   * 图标
   */
  icon?: ImageSource;

  /**
   * 透明度 [0, 1]
   *
   * @platform android
   */
  opacity?: WithDefault<Float, 1>;

  /**
   * 是否可拖拽
   */
  draggable?: boolean;

  /**
   * 是否平贴地图
   *
   * @platform android
   */
  flat?: boolean;

  /**
   * 层级 zIndex属性在ViewProps已经存在
   */
  markerIndex?: Int32;

  /**
   * 覆盖物锚点比例
   *
   * @link http://a.amap.com/lbs/static/unzip/Android_Map_Doc/3D/com/amap/api/maps/model/Marker.html#setAnchor-float-float-
   * @platform android
   */
   anchor?: Point;

  /**
   * 覆盖物偏移位置
   *
   * @link http://a.amap.com/lbs/static/unzip/iOS_Map_Doc/AMap_iOS_API_Doc_3D/interface_m_a_annotation_view.html#a78f23c1e6a6d92faf12a00877ac278a7
   * @platform ios
   */
  centerOffset?: Point;
  /**
   * 点击事件
   */
  onPress?: BubblingEventHandler<null> | null;

  /**
   * 拖放开始事件
   */
  // onDragStart?: () => void;

  /**
   * 拖放进行事件，类似于 mousemove，在结束之前会不断调用
   */
  // onDrag?: () => void;

  /**
   * 拖放结束事件
   */
  // onDragEnd?: (event: NativeSyntheticEvent<LatLng>) => void;
}

// 定义ref调用方法
interface NativeCommands {
  update: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['update'],
});

export default codegenNativeComponent<NativeProps>('MapMarker') as HostComponent<NativeProps>;
