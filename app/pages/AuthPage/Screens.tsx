/**
 * @description: Login page screens
*/
import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { bar_config_base, bar_config_hide } from '@/utils/navigationBarConfig';
import PhoneLogin from './PhoneLogin/index'; //手机号登录
// import PasswordLogin from './PasswordLogin/index'; //密码登录
// import Register from './Register/index'; //注册
// import ForgetPassword from './ForgetPassword/index'; //忘记密码
import PhoneCode from './PhoneCode';

const Stack = createNativeStackNavigator()

const AuthScreens = [
  {
    name: 'auth.PhoneLogin',
    component: PhoneLogin,
    options: { title: '手机号登录' }
  },
  {
    name: 'auth.PhoneCode',
    component: PhoneCode,
    options: {title: '手机验证码登陆' }
  }
]
export const AuthStack = () => {
  return (
    <Stack.Navigator 
      screenOptions={bar_config_base as any}
    >
      {AuthScreens.map((item, index) => (
        <Stack.Screen 
          key={index} 
          name={item.name} 
          component={item.component} 
          options={item.options} 
        />
      ))}
    </Stack.Navigator>
  )
}

export default AuthScreens;