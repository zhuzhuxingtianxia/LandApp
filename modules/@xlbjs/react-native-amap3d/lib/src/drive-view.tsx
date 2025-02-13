import React from 'react';
import {  NativeSyntheticEvent, requireNativeComponent ,ViewProps,StyleSheet} from "react-native";
import { NaviCompositeBroadcastType,NaviViewMapModeType ,NaviDrivingStrategy,NaviViewTrackingMode} from "./types";
import Component from "./component";
import PropTypes from 'prop-types';


export interface DriveNaviViewProps extends ViewProps {


/**
 * 设置比例尺智能缩放. 锁车模式下是否为了预见下一导航动作自动缩放地图. 默认为YES
 */
autoZoomMapLevel?:boolean ;
/**
 * 导航界面中的地图样式类型
 */
  mapViewModeType?:NaviViewMapModeType;
  /**
 * 导航组件中的语音播报类型
 */
  broadcastType?:NaviCompositeBroadcastType;
/**
*  导航界面跟随模式
*/
trackingMode?:NaviViewTrackingMode;
    /**
   * 导航界面设置按钮点击时的回调函数
   */
    onMoreButtonClicked:(event: NativeSyntheticEvent<{msg:any}>) => void;
    /**
     * 导航界面关闭按钮点击时的回调函数
     */
    onCloseButtonClicked?: (event: NativeSyntheticEvent<{msg:any}>) => void;

    /**
     * 到达目的地
     */
    onDidEndEmulatorNavi?: (event: NativeSyntheticEvent<{msg:any}>) => void;

}

const DriveNaviView = requireNativeComponent<DriveNaviViewProps>("DriveNaviView");



export default class extends Component<DriveNaviViewProps> {
  state = { loaded: false };
  // const [loaded, setLoaded] = useState<any>(false)

  // useEffect(()=>{
  //   setTimeout(() => setLoaded(true), 0);
  // },[])
  // let { style } = props
  componentDidMount() {
    super.componentDidMount();
    // 无论如何也要在 1 秒后 setLoaded(true) ，防止 onLoad 事件不触发的情况下显示不正常
    // 目前只在 iOS 上低概率出现
    setTimeout(() => this.setState({ loaded: true }), 500);
  }

  render() {
    let { style } = this.props;
    if (!this.state.loaded) {
      style = [style, { width: 1, height: 1 }];
    }
    return <DriveNaviView {...this.props} style ={style} />
      
  }
  
};

