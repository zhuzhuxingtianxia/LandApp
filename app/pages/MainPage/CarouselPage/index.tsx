
import { Button, Carousel } from '@ant-design/react-native'
import React, { useState } from 'react'
import { ScrollView, StyleSheet, Text, View } from 'react-native'

const CarouselPage = () => {

    const carousel = React.useRef<any>();
    const [selectedIndex, setSelectedIndex] = useState<number>(2);
    const [autoplay, setAutoplay] = useState<boolean>(true);

    const onHorizontalSelectedIndexChange = (index: number) => {
        /* tslint:disable: no-console */
        console.log('horizontal change to', index)
        setSelectedIndex(index);
      }
      const onVerticalSelectedIndexChange = (index: number) =>{
        /* tslint:disable: no-console */
        console.log('vertical change to', index)
      }

    return (
        <ScrollView style={{ paddingTop: 30 }}>
            <View style={{ paddingHorizontal: 15 }}>
                <Text>horizontal</Text>
                <Carousel
                    style={styles.wrapper}
                    selectedIndex={selectedIndex}
                    autoplay
                    infinite
                    afterChange={onHorizontalSelectedIndexChange}
                    ref={carousel}>
                    <View
                        style={[styles.containerHorizontal, { backgroundColor: 'red' }]}>
                        <Text>Carousel 1</Text>
                    </View>
                    <View
                        style={[styles.containerHorizontal, { backgroundColor: 'blue' }]}>
                        <Text>Carousel 2</Text>
                    </View>
                    <View
                        style={[
                            styles.containerHorizontal,
                            { backgroundColor: 'yellow' },
                        ]}>
                        <Text>Carousel 3</Text>
                    </View>
                    <View
                        style={[styles.containerHorizontal, { backgroundColor: 'aqua' }]}>
                        <Text>Carousel 4</Text>
                    </View>
                    <View
                        style={[
                            styles.containerHorizontal,
                            { backgroundColor: 'fuchsia' },
                        ]}>
                        <Text>Carousel 5</Text>
                    </View>
                </Carousel>
                <Button onPress={() => carousel && carousel.current.goTo(0)}>
                    Go to 0
                </Button>
            </View>
            <View style={{ paddingHorizontal: 15 }}>
                <Text>vertical</Text>
                <Carousel
                    style={styles.wrapper}
                    selectedIndex={1}
                    autoplay={autoplay}
                    infinite
                    afterChange={onVerticalSelectedIndexChange}
                    vertical>
                    <View
                        style={[styles.containerVertical, { backgroundColor: 'red' }]}>
                        <Text>Carousel 1</Text>
                    </View>
                    <View
                        style={[styles.containerVertical, { backgroundColor: 'blue' }]}>
                        <Text>Carousel 2</Text>
                    </View>
                    <View
                        style={[styles.containerVertical, { backgroundColor: 'yellow' }]}>
                        <Text>Carousel 3</Text>
                    </View>
                    <View
                        style={[styles.containerVertical, { backgroundColor: 'aqua' }]}>
                        <Text>Carousel 4</Text>
                    </View>
                    <View
                        style={[
                            styles.containerVertical,
                            { backgroundColor: 'fuchsia' },
                        ]}>
                        <Text>Carousel 5</Text>
                    </View>
                </Carousel>
                <Button
                    onPress={() => {
                        setAutoplay(!autoplay)
                    }}>
                    {`Toggle autoplay ${autoplay ? 'true' : 'false'}`}
                </Button>
            </View>
        </ScrollView>
    )
}

const styles = StyleSheet.create({
    wrapper: {
        backgroundColor: '#fff',
        width: '100%',
        height: 150,
    },
    containerHorizontal: {
        flexGrow: 1,
        alignItems: 'center',
        justifyContent: 'center',
    },
    containerVertical: {
        flexGrow: 1,
        alignItems: 'center',
        justifyContent: 'center',
    },
    text: {
        color: '#fff',
        fontSize: 36,
    },
})


export default CarouselPage;