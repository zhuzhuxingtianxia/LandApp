/**
 * @description Navigation bar config
*/

import React from 'react';
import { Image, ImageSourcePropType, Platform } from 'react-native';
const iconBack = require('@assets/icon/icon_back.png');
const iconBackWhite = require('@assets/icon/icon_back_white.png');

function backIcon(icon: ImageSourcePropType) {
    return (
      <Image
        source={icon}
        style={{
          marginLeft: Platform.OS === 'ios' ? 15 : 4,
        }}
      />
    );
}

export const bar_config_base = {
    headerTintColor: '#22385A',
    headerStyle: {
      backgroundColor: '#ffffff',
    },
    headerTitleStyle: {
      fontSize: 18,
    },
    headerBackImage: () => backIcon(iconBack),
    tabBarVisible: false,
    // 隐藏返回按钮中的文本
    headerBackButtonDisplayMode: 'minimal',
    headerBackTitleVisible: false,//该属性已无效
    headerTitleAlign: 'center',
};

// 头部配置（导航栏下方没有边框线）
export const bar_config_no_border = {
    headerTintColor: '#22385A',
    headerStyle: {
      backgroundColor: '#ffffff',
      borderBottomColor: 'rgba(0, 0, 0, 0)',
      shadowColor: 'rgba(0, 0, 0, 0)',
      elevation: 0, //解决安卓去掉边框线兼容
    },
    headerTitleStyle: {
      fontSize: 18,
    },
    headerBackImage: () => backIcon(iconBack),
    headerTitleAlign: 'center',
    tabBarVisible: false,
    headerBackButtonDisplayMode: 'minimal',
    headerBackTitleVisible: false,
  };
  
  export const bar_config_transparent = {
    headerTintColor: '#FFFFFF',
    headerTitleStyle: {
      fontSize: 18,
    },
    headerBackImage: () => backIcon(iconBackWhite),
    headerTitleAlign: 'center',
    headerTransparent: true,
    headerBackButtonDisplayMode: 'minimal',
    headerBackTitleVisible: false,
  };
  
  export const bar_config_hide = {
    headerShown: false,
  };