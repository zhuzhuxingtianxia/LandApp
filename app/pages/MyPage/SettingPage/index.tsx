
import { useNavigation, useRoute } from '@react-navigation/native';
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

const SettingPage = (props: any) => {
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
            <View style={styles.h2box}>
                <Text style={styles.h2txt}>{'SettingPage'}</Text>

                <TouchableOpacity
                    style={styles.link}
                    activeOpacity={0.8}
                    onPress={onPress}
                >
                    <Text style={styles.txt}>{"返回"}</Text>
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

export default SettingPage;