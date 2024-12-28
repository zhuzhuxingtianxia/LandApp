
import { useNavigation, useRoute } from '@react-navigation/native';
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Image, ScrollView, Platform } from 'react-native';
import { Main, Auth } from '@/pages/Launch/RouteConst';
import { Toast } from '@ant-design/react-native';
import Service from '@/services/request';

const Home = (props: any) => {
    const navigation = useNavigation<any>();
    const route = useRoute<any>();
    const { key } = route.params ?? {};
    const onPress = (item: { title: string; key: string | null }) => {
        // navigation.push('auth.PhoneCode');
        if (item.key) {
            navigation.navigate(item.key);
        } else {
            Toast.info('敬请期待');
        }

    }

    const getData = async () => {
        const loading = Toast.loading('加载中...');
        const params = {
            type: Platform.OS === 'ios' ? 'ios' : 'android',
            version: '2.4.20',
            build: '100',
            channel: 'IOS',
            mobile: '',
            token: ''
        };
       const res =  await Service.get(`/api/appConfig/listNew`, {
        params: params,
        headers: {token: ''}
       });
       setTimeout(() => {
            Toast.remove(loading);
       }, 2000);
       
       console.log(res);
       
    }

    return (
        <View style={styles.box}>
            <View style={styles.h2box}>
                <Text style={styles.h2txt}>{'Home'}</Text>
            </View>
            <ScrollView
                style={styles.Scroll}
                horizontal={false}
                contentContainerStyle={styles.contentStyle} 
                showsVerticalScrollIndicator={true}
            // onScroll={() => {}}
            // automaticallyAdjustContentInsets={false}
            // scrollEventThrottle={16}
            >
                <TouchableOpacity
                    style={styles.link}
                    activeOpacity={0.8}
                    onPress={getData}
                >
                    <Text style={styles.txt}>{'请求获取数据'}</Text>
                </TouchableOpacity>
        
                {
                    [{ title: '跳转Login', key: Auth.Login },
                    { title: '跳转H5', key: Main.H5 },
                    { title: '测试异常', key: Main.FailingComponent },
                    { title: '跳转Blur', key: Main.Blur },
                    { title: '跳转Gradient', key: Main.Gradient },
                    { title: '跳转Video', key: Main.Video },
                    { title: '跳转Masked', key: Main.Masked_View },
                    { title: '跳转ImagePicke', key: Main.ImagePickerPage },
                    { title: '跳转CarouselPage', key: Main.CarouselPage },
                    { title: '跳转QRCodePage', key: Main.QRCodePage },
                    { title: '跳转LottiePage', key: Main.LottiePage },
                    { title: '跳转瀑布流', key: null },
                    { title: '跳转图表-柱状图', key: null },
                    { title: '跳转图表-折线图', key: null },
                    { title: '跳转图表-pipe图', key: null },
                    ].map((item, index) => {
                        return (
                            <TouchableOpacity
                                style={styles.link}
                                key={index}
                                activeOpacity={0.8}
                                onPress={() => onPress(item)}
                            >
                                <Text style={styles.txt}>{item.title}</Text>
                            </TouchableOpacity>
                        )
                    })
                }
            </ScrollView>
        </View>
    )
}

const styles = StyleSheet.create({
    box: {
        flex: 1,
    },
    h2box: {
        marginTop: 60,
        alignItems: 'center'
    },
    h2txt: {
        fontSize: 18,
        color: '#22385A',
    },
    Scroll: {
        width: '100%',
        flex: 1,
    },
    contentStyle: {
        paddingHorizontal: 20,
        paddingBottom: 25,
    },
    link: {
        marginTop: 20,
        justifyContent: 'center',
        alignItems: 'center',
        height: 44,
    },
    txt: {
        fontSize: 14,
        color: '#0C59FF',
    },
})

export default Home;