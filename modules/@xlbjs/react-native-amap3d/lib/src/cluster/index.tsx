import * as React from "react";
import { ViewStyle } from "react-native";
import Supercluster, { ClusterFeature, ClusterProperties } from "supercluster";
import { CameraEvent } from "../map-view";
import { LatLng } from "../types";
import ClusterView from "./cluster-view";

export interface ClusterParams {
  /**
   * 唯一标识
   */
  id: number;

  /**
   * 包含的 Marker 数量
   */
  count: number;

  /**
   * 坐标
   */
  position: LatLng;
}

interface ClusterPoint {
  /**
   * 坐标
   */
  position: LatLng;

  /**
   * 携带的数据，可以是任意类型
   */
  properties?: any;
}

export interface ClusterProps {
  /**
   * 聚合半径
   */
  radius?: number;

  /**
   * 聚合点样式
   */
  clusterStyle?: ViewStyle;

  /**
   * 聚合点文本样式
   */
  clusterTextStyle?: ViewStyle;

  /**
   * 坐标点列表
   */
  points: ClusterPoint[];

  /**
   * 渲染 Marker
   */
  renderMarker?: (item: ClusterPoint) => React.ReactNode;

  /**
   * 渲染聚合点
   */
  renderCluster?: (params: ClusterParams) => React.ComponentType<any>;

  /**
   * 聚合点点击事件
   */
  onPress?: (params: ClusterParams) => void;
}

export interface ClusterRef {
  update: (status: CameraEvent) => void;
}

const defaultProps = { radius: 200 };

const Cluster = React.forwardRef((prop: ClusterProps, ref: React.Ref<ClusterRef>) => {
  const props = { ...defaultProps, ...prop };
  const [clusters, setClusters] = React.useState<ClusterFeature<ClusterProperties>>([]);
  const statusRef = React.useRef<CameraEvent>();
  const clusterRef = React.useRef<Supercluster<any, ClusterProperties>>();

  React.useEffect(() => {
    init();
    return () => {
      clusterRef.current = null;
    }
  },[props.points]);

  React.useImperativeHandle(ref, () => ({
    update,
  }))

  const init = async () => {
    const { radius, points } = props;
    // 如果主线程占用太多计算资源，会导致 ios onLoad 事件无法触发，非常蛋疼
    // 暂时想到的解决办法是等一个事件循环
    await new Promise((resolve) => setTimeout(resolve, 0));
    const options = { radius, minZoom: 3, maxZoom: 19 };
    const mypoints = points.map((marker) => ({
        type: "Feature",
        geometry: {
          type: "Point",
          coordinates: [marker.position.longitude, marker.position.latitude],
        },
        properties: marker.properties,
      }));
    clusterRef.current = new Supercluster<any, ClusterProperties>(options).load(mypoints);
    if (statusRef.current) {
      update(statusRef.current);
    }
  }

  /**
   * 需要在 MapView.onCameraIdle({ nativeEvent }) 回调里调用，参数为 nativeEvent
   */
  const update = async (status: CameraEvent) => {
    statusRef.current = status;
    await new Promise((resolve) => setTimeout(resolve, 0));
    const { cameraPosition, latLngBounds } = status;
    const { southwest, northeast } = latLngBounds;
    const clusters = clusterRef.current!.getClusters(
      [southwest.longitude, southwest.latitude, northeast.longitude, northeast.latitude],
      Math.round(cameraPosition.zoom!)
    );
    setClusters(clusters);
  }

  const renderCluster = (cluster: ClusterParams) => {
    return (
      <ClusterView
        key={cluster.id}
        cluster={cluster}
        onPress={props.onPress}
        style={props.clusterStyle}
        textStyle={props.clusterTextStyle}
      />
    );
  };

  const views = React.useMemo(()=>{
    const _render = props.renderCluster || renderCluster;
    const views = clusters.map(({ geometry, properties }: ClusterFeature<ClusterProperties>, i: number) => {
      const position = {
        latitude: geometry.coordinates[1],
        longitude: geometry.coordinates[0],
      };
      if (properties.point_count > 0) {
        const { cluster_id, point_count } = properties;
        return <React.Fragment key={`marker-${i}`}>
          {_render({ position, id: cluster_id, count: point_count }) as any}
        </React.Fragment>
      }
      return (
        <React.Fragment key={`marker-${i}`}>
          {props.renderMarker?.({ position, properties })}
        </React.Fragment>
      );
    });
    return views;
  },[clusters]);

  return (
    views
  );
});

export default Cluster;