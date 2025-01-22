
import React, { useEffect } from 'react';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useDispatch } from '@utils/context';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

type NavigationProp = NativeStackNavigationProp<any>;

const PhoneLogin = (props: any) => {
  const navigation = useNavigation<NavigationProp>();
  const dispatch = useDispatch();

  useEffect(() => {

  }, [])

  const onPress = () => {
    navigation.navigate('auth.PhoneCode', { key: '006600' });
  }

  const onLogin = () => {
    dispatch({ type: 'AUTH_LOGIN', payload: { token: 'hasToken' } })
  }

  return (
    <View style={styles.box}>
      <View style={styles.h2box}>
        <Text style={styles.h2txt}>{'手机号登录'}</Text>
        <TouchableOpacity
          style={styles.link}
          activeOpacity={0.8}
          onPress={onPress}
        >
          <Text style={styles.txt}>{"获取验证码"}</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.link}
          activeOpacity={0.8}
          onPress={onLogin}
        >
          <Text style={styles.txt}>{"账号密码登录"}</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  box: {
    flex: 1,
    alignItems: 'center',
  },
  h2box: {
    marginTop: 11,
  },
  h2txt: {
    fontSize: 18,
    color: '#22385A',
  },
  link: {
    marginTop: 20.5,
    width: 100,
    justifyContent: 'center',
    alignItems: 'flex-start',
    height: 44,
  },
  txt: {
    fontSize: 14,
    color: '#0C59FF',
  },
});

export default PhoneLogin;
