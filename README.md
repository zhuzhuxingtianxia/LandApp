# LandApp
react-native0.76.0

## 使用的库

* @react-navigation/native
```
yarn add @react-navigation/native
yarn add react-native-screens react-native-safe-area-context
yarn add @react-navigation/native-stack
yarn add @react-navigation/bottom-tabs
// 然后执行
npx pod-install ios
```
* @react-native-async-storage/async-storage
* react-native-storage: 存储及配置 (可不用)
* react-native-webview: webView组件, 13.12.4版本有bug
* @react-native-community/blur: 模糊
* @reduxjs/toolkit: 状态管理及请求管理
* react-native-permissions: 权限管理库
* react-native-safe-area-context: 安全区域库
* @ant-design/react-native: 组件库
* react-native-social: react-native-umeng 需支持推送，数据分析，分享，支付
* react-native-linear-gradient: 渐变库
* @react-native-masked-view/masked-view: 遮罩库
* react-native-orientation-locker: 转屏库
* react-native-video: 视频播放器库
* react-native-image-picker / react-native-image-crop-picker: 图库选择器，需要相机、相册、麦克风权限
* react-native-vision-camera/@react-native-camera-roll/camera-roll: 需相机权限
* react-native-image-zoom-viewer: 图片预览，5年没维护了
* react-native-image-pan-zoom: 图片预览,存档。5年没维护了
* react-native-pager-view: 轮播图(可使用antd)
* react-native-swiper/react-native-snap-carousel: 轮播图, 5年没更新(可使用antd)
* @react-native-community/slider：滑块(可使用antd)
* react-native-qrcode-svg: 二维码
```
yarn add react-native-svg react-native-qrcode-svg
```

* react-native-pdf: pdf文件加载库
```
yarn add react-native-pdf react-native-blob-util
```
* react-native-shadow-2: 阴影，rn0.76开始支持阴影功能。
* react-native-view-shot: 视图转图片
* react-native-reanimated/lottie-react-native: 动画库
* react-native-device-info: 获取设备及应用信息
* dayjs/moment: 日期格式化库
* react-native-live-audio-stream: 实时音频流录制
* react-native-audio-recorder-player: 录音播放
* react-native-fs: 文件操作库
* 
* victory-native: 图表库（推荐）
```
// 配置react-native-reanimated
yarn add react-native-reanimated react-native-gesture-handler @shopify/react-native-skia
yarn add victory-native
```
* @wuba/react-native-echarts: 58 图表库
* react-native-svg-charts: 图表库，5年未更新
* react-native-chart-kit: 图表库，3年未更新
* clchart: 股票图表库，6年未更新
* @react-native-seoul/masonry-list: 瀑布流
* crypto-js 和 jsencrypt: 加密解密库
* @sdcx/keyboard-insets: 键盘处理库
* react-native-update: 热更库, [收费](https://pushy.reactnative.cn/docs/getting-started)
* react-native-code-push: 热更库,appcenter是收费的。可搭建私有服务
* cpcn-react-native: [codepush中国](http://code-push.cn/docs/1010.htm) 
* @sentry/react-native: 用于错误及监控平台,配置有些复杂,而且需注册账户,独立开发小项目免费
* react-native-i18n: 多语言库，6年未更新
* react-native-localize i18n-js : 多语言库，使用这两个库配合实现多语言（推荐）。也可自己配置实现
* react-native-pull: 下拉刷新组件，不涉及原生。适合[自定义二次开发](https://www.showapi.com/news/article/66f8d3ed4ddd79f11a211f2e) 

## 配置别名
```
yarn add --dev babel-plugin-module-resolver
```
需要在babel.config.js中配置，还需要修改tsconfig.json文件

## 路由导航配置

### 静态导航
```
const RootStack = createNativeStackNavigator({
    initialRouteName: 'Home',
    // 统一导航样式，这些样式属性也可在screens.Home.options中配置。
    screenOptions: {
        headerStyle: { 
            backgroundColor: '#f4511e' 
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
          fontWeight: 'bold',
        },
    },
    screens: {
        //Home: HomeScreen,
        //或可配置参数
        Home: {
            screen: HomeScreen,
            options: {
                title: '导航标题',
                // 或自定义标题
                headerTitle: (props) => <LogoTitle {...props} />, 
            },
        },
        Details: DetailsScreen,
    },
});

const Navigation = createStaticNavigation(RootStack);

export default function App() {
  return <Navigation />;
}

//动态设置导航栏
navigation.setOptions({ title: 'Updated!' })
// 是否需要在options中配置占位符
navigation.setOptions({
    headerRight: () => (
        <Button onPress={() => setCount((c) => c + 1)}>Update count</Button>
    ),
});

```

### 动态导航
```
const Stack = createNativeStackNavigator();

function RootStack() {
  return (
    <Stack.Navigator 
        initialRouteName="Home"
        screenOptions={{
            headerStyle: { backgroundColor: 'tomato' },
        }}
    >
      <Stack.Screen 
        name="Home" 
        component={HomeScreen} 
        //options={{ title: '标题' }}
        //或
        options={({ route }) => ({
          title: route.params.name,
          // 隐藏导航栏
          headerShown: false
        })}
    />
      <Stack.Screen name="Details" component={DetailsScreen} />
    </Stack.Navigator>
  );
}

export default function App() {
  return (
    <NavigationContainer>
      <RootStack />
    </NavigationContainer>
  );
}
```

## 运行

```bash
yarn start
```

## Android

```bash
yarn android
```

## iOS

```bash
yarn ios
```

## RN项目结构设计

```
<SafeAreaProvider>
  <NavigationContainer>
      <Provider theme={antd}>
      <Context.Provider/>
      </Provider>
  </NavigationContainer>
</SafeAreaProvider>

// 全局数据初始化操作
<Context.Provider>
  <Redux.Provider>
    <RootStack/>
  <Redux.Provider>
</Context.Provider>

// 构建根路由
<RootStack.Navigator mode="modal">
  <RootStack.Screen name="Home" component={MainStack} />
  <RootStack.Screen name="Details" component={OtherScreen} />
</RootStack.Navigator>


// MainStack路由
<MainStack.Navigator initialRouteName="home">
    <MainStack.Screen
      name="home"
      options={{ ...no_head, title: '首页' }}
      component={HomeTab}
    />
    <MainStack.Screen
      name="guide"
      options={{ ...no_head, title: '引导页' }}
      component={Guide}
    />
    <MainStack.Screen
      name="ad"
      options={{ ...no_head, title: '广告页' }}
      component={Ad}
    />
</MainStack.Navigator>

// HomeTab路由
<Tab.Navigator>
  <Tab.Screen></Tab.Screen>
  <Tab.Screen></Tab.Screen>
</Tab.Navigator>

```

## svg图片加载
 "react-native-svg-transformer": "^1.5.0",
 使用该库加载svg图片渲染报错。
```
import {SvgUri} from 'react-native-svg';
<SvgUri width="30" height="30" uri="https://github.githubassets.com/images/modules/logos_page/Octocat.png" />
```