import { Dimensions, findNodeHandle, LayoutRectangle, Platform, UIManager, View, type TextStyle } from 'react-native';
const ScreenWidth = Dimensions.get('window').width;
const rpx = (px: number) => ScreenWidth / 375 * px;
// 获取正确的屏幕高度，解决android全面屏获取的高度会少了一个状态栏的高度
function getRealScreenHeight() {
  let height = Dimensions.get('window').height;
  if (Platform.OS === 'android') {
    const screenH = Dimensions.get('screen').height;
    // 判断是否是全面屏幕，全面屏screen和window
    if (screenH > height) {
      height = screenH;
    }
  }
  return height;
}
const ScreenHeight = getRealScreenHeight();

const getScreenCoordinates = async (viewRef: React.RefObject<View>):Promise<LayoutRectangle> => {
  return new Promise((resolve, reject) => {
    if (!viewRef.current) {
      reject(new Error('viewRef.current is null'));
      return;
    }
    if (Platform.OS === 'android') {
      // For Android
      UIManager.measure(findNodeHandle(viewRef.current) as number, (x, y, width, height, pageX, pageY) => {
        resolve({ x: pageX, y: pageY, width, height });
      });
    } else {
      // For iOS
      viewRef.current?.measure((fx, fy, width, height, pageX, pageY) => {
        resolve({ x: pageX, y: pageY, width, height });
      });
    }
  });

};

const fontStyle = (size?: number, color?: string, weight?: TextStyle['fontWeight']): TextStyle => {
    return {
        fontSize: size ?? 12,
        color: color ?? '#000',
        fontWeight: weight ?? '600',
    };
};

const borderStyle = (width?: number, borderRadius?: number, color?: string) => {
    return {
        borderWidth: width ?? 1,
        borderColor: color ?? '#999',
        borderRadius: borderRadius ?? 0,
    };
};

export {
    rpx,
    ScreenHeight,
    ScreenWidth,
    getScreenCoordinates,
    fontStyle,
    borderStyle,
};
