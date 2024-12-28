
import { useNavigation, useRoute } from '@react-navigation/native';
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { WebView } from 'react-native-webview';

const H5 = (props: any) => {
    const navigation = useNavigation<any>();
    const route = useRoute<any>();
    const { key } = route.params ?? {};
    const onPress = () => {
        navigation.goBack()
    }

    const onPressAgain = () => {
        navigation.push('auth.PhoneCode');
    }

    return (
        <View style={styles.box}>
            <WebView
                source={{ uri: 'https://www.baidu.com/' }}
                style={{ paddingTop: 20, flex:1 }}
            />
        </View>
    )
}

const styles = StyleSheet.create({
    box: {
        flex: 1,
    }
})

export default H5;