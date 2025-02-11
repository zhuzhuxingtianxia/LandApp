
import { bar_config_base, bar_config_hide } from '@/utils/navigationBarConfig';
import { Find } from '@pages/Launch/RouteConst';
import React from 'react';
import { View } from 'react-native';
const FindScreens = [
    {
      name: Find.Home,
      component: <View />,
      options: {
        ...bar_config_hide,
        title: '发现',
      },
    },
];

export default FindScreens;