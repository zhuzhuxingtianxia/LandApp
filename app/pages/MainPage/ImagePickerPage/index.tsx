import React, { useRef } from 'react';
import { Dimensions, Image, Modal, StyleSheet, Text, TouchableHighlight, TouchableOpacity, View } from 'react-native';
import ImagePicker from 'react-native-image-crop-picker';
import { simpleStyle } from 'react-native-image-zoom-viewer/src/image-viewer.style';

// 该库存在问题
import ImageViewer from 'react-native-image-zoom-viewer';
import ImageZoom from 'react-native-image-pan-zoom';

const ScreenHeight = Dimensions.get('window').height;
const ScreenWidth = Dimensions.get('window').width;

const ImagePickerPage = () => {

    const [images, setImages] = React.useState<any[]>([])
    const [preImgs, setPreImgs] = React.useState<any[]>([])
    const [visible, setVisible] = React.useState(false);
    const [index, setIndex] = React.useState(0);

    const onPress = () => {
        ImagePicker.openPicker({
            width: 300,
            height: 400,
            multiple: true,
            minFiles: 1,
            maxFiles: 5,
            cropping: true
        }).then(images => {
            /*
                {"creationDate": "1299975445", 
                "cropRect": {"height": 2847, "width": 2139, "x": 1077, "y": 0}, 
                "data": null, 
                "duration": null, 
                "exif": null, 
                "filename": "IMG_0001.JPG", 
                "height": 399, 
                "localIdentifier": "106E99A1-4F6A-45A2-B320-B0AD4A8E8473/L0/001", 
                "mime": "image/jpeg", 
                "modificationDate": null, 
                "path": "/Users/jion/Library/Developer/CoreSimulator/Devices/6CC596FB-2988-47DF-A735-F1AAF4C5EF19/data/Containers/Data/Application/94A657C3-8EE7-4F1E-A1EB-041AC61D2B48/tmp/react-native-image-crop-picker/9CFB8552-10B3-444F-9F74-DCF497756839.jpg", 
                "size": 33696, 
                "sourceURL": "file:///Users/jion/Library/Developer/CoreSimulator/Devices/6CC596FB-2988-47DF-A735-F1AAF4C5EF19/data/Media/DCIM/100APPLE/IMG_0001.JPG", 
                "width": 300}
            */
            // console.log(images);
            setImages(images);
            const newImages = images.map((item) => {
                return {
                    url: item.path,
                    props: {
                        resizeMode: 'contain',
                        width: ScreenWidth,
                        height: ScreenHeight*0.5,
                        // source: {uri: item.path},
                    },
                }
            })
            setPreImgs([{
                url: '',
                props: {
                    source: require('@assets/imgs/img1.jpg'),
                },
            }, ...newImages])
        }).catch(e => {
            console.log(e);
        });
    }

    const onPrewView = (index: number) => {
        setIndex(index);
        setVisible(true);
    }

    return (
        <View style={{ alignItems: 'center' }}>
            <View style={{ width: '100%', flexDirection: 'row', flexWrap: 'wrap', padding: 10 }}>
                {
                    images.map((img, index) => {
                        return (
                            <TouchableHighlight key={index} onPress={() => onPrewView(index)}>
                                <Image style={{ width: 110, height: 110, margin: 5 }} key={index} source={{ uri: img?.path }} />
                            </TouchableHighlight>
                        )
                    })
                }
            </View>
            <TouchableOpacity
                style={styles.link}
                activeOpacity={0.8}
                onPress={() => onPress()}
            >
                <Text style={styles.txt}>{'选择图片'}</Text>
            </TouchableOpacity>
            <Modal transparent={true} visible={visible}>
                <ImageViewer 
                    index={index}
                    // show={visible}
                    // onSwipeDown={() => setVisible(false)}
                    onClick={()=>setVisible(false)}
                    saveToLocalByLongPress={false}
                    renderIndicator={(currentIndex, allSize) => {
                        // return <></>;
                        return React.createElement(
                            View,
                            { style: {...simpleStyle.count, top: 64} },
                            React.createElement(Text, { style: simpleStyle.countText }, currentIndex + '/' + allSize)
                          );
                    }}
                    imageUrls={preImgs} 
                />
                {/* <ImageZoom cropWidth={ScreenWidth}
                    cropHeight={ScreenHeight}
                    imageWidth={ScreenWidth}
                    imageHeight={ScreenHeight}
                    onClick={()=>setVisible(false)}
                    style={{backgroundColor: 'rgba(0,0,0,0.9)'}}
                >
                    <Image style={{ width: ScreenWidth, height: ScreenHeight }}
                        resizeMode='contain'
                        source={require('@assets/imgs/img1.jpg')} />
                </ImageZoom> */}
            </Modal>
        </View>
    )
}

const styles = StyleSheet.create({
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
});

export default ImagePickerPage;