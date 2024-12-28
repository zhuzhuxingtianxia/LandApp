/**
 * @description 广告页
*/

import React, { useEffect, useState } from 'react';
import { useNavigation } from '@react-navigation/native';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useDispatch } from '@/utils/context';

const Ad = (props: any) => {
    const navigation = useNavigation<any>();
    const dispatch = useDispatch();
    const [timer, setTimer] = useState<number>(5);
    const [showAdd, setShowAdd] = useState<boolean>(true);

    useEffect(() => {
        let interval: number | NodeJS.Timeout = 0;
        jump();
        function jump() {
            interval = setInterval(() => {
                if (timer > 0) {
                    const _timer = timer - 1;
                    setTimer(_timer);
                }
                if (timer === 0) {
                    clearInterval(interval);
                    onPress();
                }
            }, 1000);
        }
        return () => {
            interval && clearInterval(interval);
        };
    }, [])

    const onPress = () => {
        setShowAdd(false);
    }

    return (
        <>
        {
            showAdd ?
            <View style={styles.box}>
                <View style={styles.h2box}>
                    <Text style={styles.h2txt}>{'广告页'}</Text>
                    <TouchableOpacity
                        style={styles.link}
                        activeOpacity={0.8}
                        onPress={onPress}
                    >
                        <Text style={styles.txt}>{timer}s后跳过</Text>
                    </TouchableOpacity>
                </View>
            </View>
            :null
        }
        </>
        
    )
}

const styles = StyleSheet.create({
    box: {
        backgroundColor: '#ff0000',
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center'
    },
    h2box: {
        marginTop: 30,
        alignItems: 'center'
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

export default Ad;