/**
 * @description 局部界面实现View组件Push动画
*/

import { ScreenWidth } from '@/utils';
import type { ClassAttributes, PropsWithChildren, ReactElement } from 'react';
import React from 'react';
import type { LayoutChangeEvent, ViewStyle } from 'react-native';
import { Animated, StyleSheet, View } from 'react-native';

export interface PushViewRef {
  push: () => void;
  pop: () => void;
}

interface PushViewProps {
  style?: ViewStyle;
}

const PushView = React.forwardRef((props: PropsWithChildren<PushViewProps>, ref: React.Ref<PushViewRef>) => {

  const translateX = React.useRef(new Animated.Value(-ScreenWidth)).current;
  const opacity = React.useRef(new Animated.Value(1.0)).current;
  const layoutRef = React.useRef<number>(0);
  const childElement = React.Children.only(props.children as ReactElement & ClassAttributes<ReactElement>);

  React.useImperativeHandle(ref, () => ({
    push: () => {
      startAnimated(true);
    },
    pop: () => {
      startAnimated(false);
    },
  }));

  const startAnimated = (isPush: boolean)=> {
    if(isPush) {
      translateX.setValue(0);
      opacity.setValue(0.3);
      Animated.parallel([
        Animated.timing(translateX, {
          toValue: -layoutRef.current,
          duration: 300,
          useNativeDriver: true,
        }),
        Animated.timing(opacity, {
          toValue: 1.0,
          duration: 200,
          useNativeDriver: true,
        }),
      ]).start(({ finished }) => {
        console.log('push-finished', finished);
        translateX.setValue(-layoutRef.current);
        opacity.setValue(1.0);
      });

    }else {
      translateX.setValue(-layoutRef.current);
      Animated.timing(translateX, {
        toValue: 0, // 返回初始位置
        duration: 300,
        useNativeDriver: true,
      }).start(({ finished }) => {
        console.log('pop-finished', finished);
        translateX.setValue(-layoutRef.current);
      });
    }

  };
  const onLayout = (event: LayoutChangeEvent) => {
    const { width } = event.nativeEvent.layout;
    layoutRef.current = width;
  };

  return (
    <View style={[styles.content, props.style]} onLayout={onLayout}>
      <Animated.View style={{ opacity: opacity }}>
        {props.children}
      </Animated.View>
      <Animated.View style={[
        styles.transformStyle,
        props.style?.backgroundColor ? {
          backgroundColor: props.style.backgroundColor,
        } : {},
        { transform: [{ translateX }] },
      ]}>
        {childElement}
      </Animated.View>
    </View>
  );
});
const styles = StyleSheet.create({
  transformStyle: {
    position: 'absolute',
    backgroundColor: '#FFF',
  },
  content: {
    overflow: 'hidden',
    position: 'relative',
    flexDirection: 'column',
    backgroundColor: '#FFFFFF',
  },
});
export default PushView;
