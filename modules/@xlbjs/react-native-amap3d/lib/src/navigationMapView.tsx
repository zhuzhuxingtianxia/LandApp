
import  React, {useEffect,useState} from "react";
import { ImageSourcePropType, NativeSyntheticEvent, requireNativeComponent ,ViewProps,View,StyleSheet,Image,Pressable} from "react-native";
import Component from "./component";
import { LatLng,MapPoi,NavigationPoints } from "./types";
import { Double } from "react-native/Libraries/Types/CodegenTypes";
import flex from "@xlb/common/src/styles/utilities/flex";


const NavigationCustomView = requireNativeComponent<NavigationMapViewProps>("NavigationCustomView");
export interface NavigationMapViewProps extends ViewProps {
  /**
   * 起点
   */
  startPoint?: MapPoi;
   /**
   * 终点
   */
   endPoint?: MapPoi;
/**
   * 途经点，最多16个
   */
  wayPoints?: MapPoi[];


  /**
   * 所有点位一次传入，可以减少算路次数，提高渲染效率
   * 起点
   * 途经点，最多16个
   * 终点
   * 
   */
  points?: NavigationPoints;

  /**
   * 路径id
   */
  routeID?: number;

  /**
   * 算路成功
   */
  onCalculateRouteSuccess?: (event: NativeSyntheticEvent<{routes:Array<any>}>) => void;
}

export default class extends Component<NavigationMapViewProps> {
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
    return <NavigationCustomView {...this.props} style ={style} />
      
  }
  
};

const styles = StyleSheet.create({
  view_content: {
    width:'100%',
    height:'100%',
    position:'relative',
    backgroundColor:'#ffffff'
  },
  map_content: {
    width:'100%',
    height:'100%',
    position:'relative',

  }
 
})
