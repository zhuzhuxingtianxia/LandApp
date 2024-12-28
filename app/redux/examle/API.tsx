
import React, { useEffect, useRef } from 'react';
import { Platform, ScrollView, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useGetAppConfigQuery, useAddAppConfigMutation } from '../services/pokemon';
import { Toast } from '@ant-design/react-native';

function generateRandomString() {
    return `${Date.now().toString(36)}`;
  }

export default function API() {
    const [token, setToken] = React.useState('');
    const params = {
        type: Platform.OS === 'ios' ? 'ios' : 'android',
        version: '2.4.20',
        build: '100',
        channel: 'IOS',
        mobile: '',
        token: token
    };
    // 自动请求
    const { data, error, isLoading, refetch } = useGetAppConfigQuery(params);
    const [addAppConfig, { isLoading: isAdding }] = useAddAppConfigMutation();

    useEffect(() => {
        let toast = null;
        if(isAdding || isLoading) {
            toast = Toast.show({
                icon: 'loading',
                content: '请求中...'
            })
        }else {
            toast && Toast.remove(toast);
        }
    },[isLoading, isAdding])

    const onLoadData = () => {
        refetch();
    }

    return (
        <View style={styles.container}>
            <ScrollView style={styles.content}
                contentContainerStyle={styles.contentStyle}
            >
                <Text style={styles.txt}>
                    {isLoading ? 'Loading...' : error ? '请求报错' : JSON.stringify(data, null, 2)}
                </Text>
            </ScrollView>
            <View style={styles.box}>
                <TouchableOpacity onPress={() => {
                    onLoadData();
                }}>
                    <Text style={styles.action}>刷新请求</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={() => {
                    setToken(generateRandomString());
                }}>
                    <Text style={styles.action}>改变参数</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={async () => {
                    const res = await addAppConfig(params);
                    console.log(res);
                }}>
                    <Text style={styles.action}>触发请求</Text>
                </TouchableOpacity>
            </View>
        </View>
    )
}

const styles = StyleSheet.create({
    container: {
        width: '100%',
        justifyContent: 'center',
        alignItems: 'center'
    },
    content: {
        height: 400,
        width: '100%',
        marginTop: 20,
    },
    contentStyle: {
        paddingHorizontal: 20,
        paddingBottom: 25,
    },
    txt: {
        fontSize: 14,
        color: '#22385A',
    },
    box: {
        marginTop: 20,
        flexDirection: 'row'
    },
    action: {
        color: '#0C59FF',
        fontSize: 18,
        marginHorizontal: 10
    }
})