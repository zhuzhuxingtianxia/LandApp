import React, { Component } from "react";
import { View, Image, Text, StyleSheet } from "react-native";
import { BlurView } from "@react-native-community/blur";

export default function Blur() {
  return (
    <View style={styles.container}>
      <Image
        key={'blurryImage'}
        source={require('@assets/imgs/img1.jpg')}
        resizeMode={'contain'}
        style={styles.absolute}
      />
      <Text>Hi, I am some blurred text</Text>
      {/* in terms of positioning and zIndex-ing everything before the BlurView will be blurred */}
      <BlurView
        style={styles.absolute}
        blurType="light"
        blurAmount={3}
        blurRadius={1}
        // reducedTransparencyFallbackColor="white"
      />
      <Text>I'm the non blurred text because I got rendered on top of the BlurView</Text>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  absolute: {
    position: "absolute",
    width: '100%',
    height: '100%',
  }
});