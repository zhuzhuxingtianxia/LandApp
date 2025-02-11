import type { PropsWithChildren } from 'react';
import React, { useState, useEffect, isValidElement } from 'react';
import { View, Text, Animated, StyleSheet } from 'react-native';
import Svg, { Circle } from 'react-native-svg';

const AnimatedCircle = Animated.createAnimatedComponent(Circle);

interface IProgressProps {
  size: number;
  strokeWidth: number;
  progress: number; // 1-100
  duration: number;
  backgroundColor: string;
  strokeColor: string;
  showContent: boolean
}

const defaultProps: IProgressProps = {
  size: 100,
  strokeWidth: 10,
  progress: 80,
  duration: 1000,
  backgroundColor: 'rgba(0, 0, 0, 0.2)',
  strokeColor: '#FF0000',
  showContent: true,
};

const CircularProgress = (p: Partial<PropsWithChildren<IProgressProps>>) => {
  const props:IProgressProps = {
    ...defaultProps,
    ...p,
  };
  const [animatedValue] = useState(new Animated.Value(0));

  useEffect(() => {
    animatedValue.setValue(0);
    // 动画的渐变效果
    Animated.timing(animatedValue, {
      toValue: Math.min(props.progress, 100),
      duration: props.duration,
      useNativeDriver: false, // 因为我们需要更新 `strokeDashoffset`
    }).start();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [props.progress]);

  const radius = (props.size - props.strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;

  // 计算 `strokeDashoffset` 使得进度条能够动态变化
  const strokeDashoffset = animatedValue.interpolate({
    inputRange: [0, 100],
    outputRange: [circumference, 0],
  });

  return (
    <View style={styles.container}>
      <Svg width={props.size} height={props.size} viewBox={`0 0 ${props.size} ${props.size}`}>
        <Circle
          cx={props.size / 2}
          cy={props.size / 2}
          r={radius}
          stroke={props.backgroundColor} // 背景颜色
          strokeWidth={props.strokeWidth}
          fill="none"
        />
        <AnimatedCircle
          cx={props.size / 2}
          cy={props.size / 2}
          r={radius}
          stroke={props.strokeColor} // 进度颜色
          strokeWidth={props.strokeWidth}
          fill="none"
          strokeLinecap="round"
          transform={`rotate(-90 ${props.size / 2} ${props.size / 2})`}
          strokeDasharray={circumference}
          strokeDashoffset={strokeDashoffset}
        />
      </Svg>
      {
        props.showContent && <View style={[styles.txtBox, { margin: props.strokeWidth }]}>
          {
            isValidElement(p.children) ? p.children :
              <Text style={styles.text}>
                {Math.round(props.progress)}%
              </Text>
          }
        </View>
      }
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  txtBox: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    position: 'absolute',
    fontSize: 10,
    fontWeight: 'bold',
  },
});

export default CircularProgress;
