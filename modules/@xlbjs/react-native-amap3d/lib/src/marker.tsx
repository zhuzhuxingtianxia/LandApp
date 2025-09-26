import * as React from 'react';
import type {
  ImageSourcePropType,
  NativeSyntheticEvent,
  ViewStyle } from 'react-native';
import {
  requireNativeComponent,
  View,
} from 'react-native';
// @ts-ignore
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';
import Component from './component';
import type { LatLng, Point } from './types';
import { MapMarker as NewMapMarker } from './fabric';

export interface MarkerProps {
  style?: ViewStyle;
  /**
   * 坐标
   */
  position: LatLng;

  /**
   * 图标
   */
  icon?: ImageSourcePropType;

  /**
   * 透明度 [0, 1]
   *
   * @platform android
   */
  opacity?: number;

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
   * 层级
   */
  zIndex?: number;

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
   * 自定义 View
   */
  children?: React.ReactNode;

  /**
   * 点击事件
   */
  onPress?: () => void;

  /**
   * 拖放开始事件
   */
  onDragStart?: () => void;

  /**
   * 拖放进行事件，类似于 mousemove，在结束之前会不断调用
   */
  onDrag?: () => void;

  /**
   * 拖放结束事件
   */
  onDragEnd?: (event: NativeSyntheticEvent<LatLng>) => void;
}

const name = 'AMapMarker';
const NativeMarker = requireNativeComponent<MarkerProps>(name);
class OldMapMarker extends Component<MarkerProps> {
  name = name;

  /**
   * 触发自定义 view 更新
   *
   * 通常来说，不需要主动调用该方法，对于 android，如果自定义 view 存在异步更新，
   * 例如，包含一个引用了网络图片的 <Image />，则需要在 view 更新后主动调用该方法触发
   * icon 更新。
   */
  update = () => {
    setTimeout(() => this.invoke('update'), 0);
  };

  componentDidUpdate() {
    if (this.props.children) {
      this.update();
    }
  }

  render() {
    const props = { ...this.props };
    // @ts-ignore android 不能用 position 作为属性，会发生冲突
    props.latLng = props.position;
    // @ts-ignore
    delete props.position;
    if (props.children) {
      props.children = (
        <View style={style} onLayout={this.update}>
          {props.children}
        </View>
      );
    }
    return <NativeMarker {...props} icon={resolveAssetSource(props.icon)} />;
  }
}

const style: ViewStyle = { position: 'absolute', zIndex: -1 };

const MapMarker = OldMapMarker;

export default MapMarker;
