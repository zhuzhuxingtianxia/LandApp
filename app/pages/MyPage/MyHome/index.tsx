

import { useNavigation, useRoute } from '@react-navigation/native';
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Image } from 'react-native';
import { Counter } from '@/redux/examle/Counter';
import API from '@/redux/examle/API';

const MyHome = (props: any) => {
    const navigation = useNavigation<any>();
    const route = useRoute<any>();
    const { key } = route.params ?? {};
    const onPress = () => {
        navigation.push('my.SettingPage');
    }

    return (
        <View style={styles.box}>
            <View style={styles.h2box}>
                <Text style={styles.h2txt}>{'MyHome'}</Text>
                <TouchableOpacity
                    style={styles.link}
                    activeOpacity={0.8}
                    onPress={onPress}
                >
                    <Text style={styles.txt}>{"跳转"}</Text>
                </TouchableOpacity>
            </View>
            <Counter />
            <API />
        </View>
    )
}

const styles = StyleSheet.create({
    box: {
        flex: 1,
        // justifyContent: 'center',
        alignItems: 'center'
    },
    h2box: {
        marginTop: 11,
        alignItems:'center'
    },
    h2txt: {
        fontSize: 18,
        color: '#22385A',
    },
    link: {
        marginTop: 20.5,
        justifyContent: 'center',
        alignItems: 'flex-start',
        height: 44,
    },
    txt: {
        fontSize: 14,
        color: '#0C59FF',
    },
})

export default MyHome;