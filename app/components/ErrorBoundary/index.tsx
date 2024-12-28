
import React from 'react';
import {
    View,
    StyleSheet,
    StatusBar,
    Dimensions,
    Text,
    TouchableOpacity,
    Image
} from 'react-native';
import { Icon } from '@ant-design/react-native';


const ScreenWidth = Dimensions.get('window').width;
const rpx = ScreenWidth / 375;

interface PState {
    hasError: boolean;
}

export default class ErrorBoundary extends React.Component <any, PState>{
    constructor(props: any) {
        super(props);
        this.state = { hasError: false };
    }

    static getDerivedStateFromError(error: any) {
        // Update state so the next render will show the fallback UI.
        return { hasError: true };
    }

    componentDidCatch(error: any, errorInfo: any) {
        // 你可以在这里记录错误信息到日志服务
        console.warn("Uncaught error:", error, errorInfo);
        // 或者发送到远程监控系统（例如 Sentry）
    }

    render() {
        if (this.state.hasError) {
            // 你可以在这里渲染一个错误页面
            return (
                <View style={styles.container}>
                    <StatusBar  barStyle={'dark-content'}/>
                    {/* <Image style={styles.icon} source={} /> */}
                    <Icon name="frown" size={80}/>
                    <Text style={styles.text}>程序出了一点问题，请重试</Text>
                    <TouchableOpacity
                        style={styles.btn}
                        onPress={() => {
                            this.setState({ hasError: false }, () => {
                                this.forceUpdate();
                            });
                        }}>
                        <Text style={styles.btnTxt}>重试</Text>
                    </TouchableOpacity>
                </View>
            )
        }
        return this.props.children;
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#f6f6f6'
    },
    icon: {
        width: rpx * 375,
        height: rpx * 360
    },
    text: {
        fontSize: rpx * 15,
        color: '#666',
        marginTop: rpx * 10,
        lineHeight: rpx * 20
    },
    btn: {
        width: rpx * 325,
        height: rpx * 45,
        marginTop: rpx * 40,
        backgroundColor: '#ff9900',
    },
    btnTxt: {
        color: '#fff',
        textAlign: 'center',
        lineHeight: rpx * 45,
        fontSize: rpx * 18,
        fontWeight: 'bold'
    }
});