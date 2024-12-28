/**
 * @description: Login page screens
*/
import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

import { bar_config_base, bar_config_hide } from '@/utils/navigationBarConfig';
import MyHome from './MyHome';

// 采用懒加载
const SettingPage = React.lazy(() => import('./SettingPage'));

const MyScreens = [
    {
      name: 'my.MyHome',
      component: MyHome,
      options: {title: '个人中心' }
    },
    {
      name: 'my.SettingPage',
      component: SettingPage,
      options: {title: '设置' }
    }
]

export default MyScreens;