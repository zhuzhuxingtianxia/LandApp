/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable react-native/no-inline-styles */

import type { PropsWithChildren } from 'react';
import React, { isValidElement, useEffect, useRef } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Svg, { Circle } from 'react-native-svg';

interface CircleProgressProps {
  size: number;
  strokeWidth: number;
  progress: number; // 0-1
  backgroundColor: string;
  strokeColor: string;
}

const defaultProps: CircleProgressProps = {
  size: 100,
  strokeWidth: 10,
  progress: 0.55,
  backgroundColor: 'rgba(0, 0, 0, 0.2)',
  strokeColor: '#4caf50',
};

const CircleProgress = (p: Partial<PropsWithChildren<CircleProgressProps>>) => {
  const props: CircleProgressProps = {
    ...defaultProps,
    ...p,
  };
  const { size, strokeWidth, progress, backgroundColor, strokeColor } = props;
  const radius = (size - 2 * strokeWidth) / 2; // 减去两倍的边框宽度得到半径
  const circumference = 2 * Math.PI * radius;

  const animatedRef = useRef<any>(null);
  const progressRef = useRef<number>(0);

  useEffect(() => {
    let interval: string | number | NodeJS.Timeout | undefined;

    if (animatedRef.current) {
      const pressValue = 1 - progress;
      progressRef.current = 1;
      interval = setInterval(() => {
        if(progressRef.current >= pressValue) {
          progressRef.current -= 0.02;
        }else {
          progressRef.current = pressValue;
          clearInterval(interval);
        }
        // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
        animatedRef.current.setNativeProps({
          strokeDashoffset: progressRef.current * circumference,
        });
      }, 10);
    }
    return () => {
      interval && clearInterval(interval);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [progress]);

  return (
    <View style={{ width: size, height: size }}>
      <Svg width={size} height={size}>
        {/* 背景圆 */}
        <Circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={backgroundColor}
          strokeWidth={strokeWidth}
          fill="none"
        />
        {/* 进度圆 */}
        <Circle
          ref={animatedRef}
          cx={size / 2}
          cy={size / 2}
          r={radius}
          stroke={strokeColor}
          strokeWidth={strokeWidth}
          fill="none"
          strokeLinecap="round"
          strokeDasharray={`${circumference} ${circumference}`}
          transform={`rotate(-90 ${size / 2} ${size / 2})`}
        />
      </Svg>
      <View style={{ ...StyleSheet.absoluteFillObject, justifyContent: 'center', alignItems: 'center', margin: strokeWidth }}>
        {
          isValidElement(p.children) ? p.children :
            <Text style={{ fontSize: 20, fontWeight: 'bold' }}>
              {Math.round(progress * 100)}%
            </Text>
        }
      </View>
    </View>
  );
};

export default CircleProgress;
