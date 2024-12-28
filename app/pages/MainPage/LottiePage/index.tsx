import React, { useState, useRef, useEffect } from 'react';
import LottieView from 'lottie-react-native';
import { Animated, Easing, Button, StyleSheet, View } from 'react-native';

const AnimatedLottieView = Animated.createAnimatedComponent(LottieView);

export default function LottiePage() {
    const animationRef = useRef<LottieView>(null);
    const [stauts, setStauts] = useState(false);

    const animationProgress = useRef(new Animated.Value(0));

    useEffect(() => {
      Animated.timing(animationProgress.current, {
        toValue: 1,
        duration: 5000,
        easing: Easing.linear,
        useNativeDriver: false,
      }).start();
    }, []);

    const onAnimationContrl = () => {
      if(stauts) {
        animationRef.current?.pause();
      }else {
        animationRef.current?.play();
      }
        setStauts(!stauts);
    }
      
  return (
    <View style={{flex: 1, alignItems: 'center', backgroundColor: '#d9d9d9'}}>
        <LottieView 
            style={[styles.container,{backgroundColor: 'red'}]}
            source={require('./json/loading.json')} 
            autoPlay
            loop
            colorFilters={[
              {
                keypath: 'ShapeLayer',
                color: 'blue',
              }
            ]}
        />
        <LottieView 
            style={[styles.container]}
            source={require('./json/default_data.json')} 
            autoPlay
            loop
        />
        <AnimatedLottieView 
            style={[styles.container]}
            source={require('./json/hi_data.json')} 
            progress={animationProgress.current}
        />
        <LottieView 
            style={[styles.container]}
            source={require('./json/g_data.json')} 
            autoPlay
            loop
            colorFilters={[
              {
                keypath: 'L-hand',
                color: '#ff0000',
              },
              {
                keypath: 'G',
                color: '#ff0000',
              },
              {
                keypath: 'body',
                color: '#ff0000',
              },
          ]}
        />
        <LottieView 
            style={styles.container}
            ref={animationRef}
            source={require('./json/data.json')} 
            autoPlay={false}
            loop={false}
            onAnimationFinish={()=>{
              console.log('动画播放结束')
              setStauts(false);
            }}
            // progress={}
            // colorFilters={[{
            //     keypath: 'button',
            //     color: '#F00000',
            // }]}
        />
        <Button title={stauts ? 'pause': 'play'} onPress={onAnimationContrl}></Button>
    </View>
    
  );
}

const styles = StyleSheet.create({
    container: {
      // backgroundColor: '#F5FCFF',
      width: 100,
      height: 100,
      marginTop: 20
    },
});