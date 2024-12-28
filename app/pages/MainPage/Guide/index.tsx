/**
 * @description 引导页
*/

import React from 'react';
import { useNavigation } from '@react-navigation/native';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useDispatch } from '@/utils/context';

const Guide = (props: any) => {
    const navigation = useNavigation<any>();
    const dispatch = useDispatch();
    const onPress = () => {
        dispatch({type: 'SET_FIRST_INSTALL', payload: {userGuide: true}});
    }

    const onPressAgain = () => {
        // navigation.push('auth.PhoneCode');
    }

    return (
        <View style={styles.box}>
            <View style={styles.h2box}>
                <Text style={styles.h2txt}>{'引导页'}</Text>
                <TouchableOpacity
                    style={styles.link}
                    activeOpacity={0.8}
                    onPress={onPress}
                >
                    <Text style={styles.txt}>{"跳过"}</Text>
                </TouchableOpacity>
            </View>
        </View>
    )
}

const styles = StyleSheet.create({
    box: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center'
    },
    h2box: {
        marginTop: 30,
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

export default Guide;