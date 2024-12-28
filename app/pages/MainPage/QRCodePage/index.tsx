import React from 'react';
import { View } from 'react-native';
import QRCode from 'react-native-qrcode-svg';

const QRCodePage = () => {
 
    return (
        <View style={{flex: 1, justifyContent: 'center', alignItems: 'center' }}>
            <QRCode value="http://awesome.link.qr"/>
            <View style={{height: 20}}></View>
            <QRCode
                value="Just some string value"
                logo={require('@assets/icon/setting-gktlogo.png')}
                logoSize={30}
                logoBackgroundColor='transparent'
            />
        </View>
    )
}

export default QRCodePage;