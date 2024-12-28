/**
 * @description: 根导航器
*/
import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { bar_config_base, bar_config_hide } from '@/utils/navigationBarConfig';
import MainScreens from '../MainPage/Screens';
import MyScreens from '../MyPage/Screens';
import Main from '../Main';
import AuthScreens from '../AuthPage/Screens';

const Stack = createNativeStackNavigator();

const Screens = [
  // ...AuthScreens,
  ...MainScreens,
  ...MyScreens
]

const RootStack = ({initialRouteName='Main'}) => {
  return (
    <Stack.Navigator
      initialRouteName={initialRouteName}
      screenOptions={bar_config_base as any}
    >
      <Stack.Screen name="Main" component={Main} 
        options={bar_config_hide as any}
      />
      {
        Screens.map((item, index) => {
          return (
            <Stack.Screen 
              key={index}
              name={item.name}
              component={item.component}
              options={item.options as any}
            />
          )
        })
      }
    </Stack.Navigator>
  );
}

export default RootStack;