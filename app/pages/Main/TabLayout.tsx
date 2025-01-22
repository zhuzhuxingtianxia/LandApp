/* eslint-disable react-native/no-inline-styles */
/* eslint-disable react/no-unstable-nested-components */
/* eslint-disable @typescript-eslint/no-unused-vars */

import React, { useState, useEffect, useCallback } from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import { Image, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import HomePage from '../MainPage/HomePage';
import MyHome from '../MyPage/MyHome';
import FindHome from '../Find/index';

import TabbarBtnHig from '@assets/tabbar/tabbar_btn_sy_hig.svg';
import TabbarBtnNor from '@assets/tabbar/tabbar_btn_sy_nor.svg';

const TabHome = require('@assets/tabbar/home-icon.png');
const TabHomeSelect = require('@assets/tabbar/home-selected-icon.png');

const TabMy = require('@assets/tabbar/mine-icon.png');
const TabMySelect = require('@assets/tabbar/mine-selected-icon.png');

const Tab = createBottomTabNavigator();

const Layout = () => {
    const [isReady, setIsReady] = useState(false);

    useEffect(() => {

    }, []);


    return (
        <Tab.Navigator
            // tabBar={(props) => <TabBar {...props} />}
            initialRouteName="HomePage"
            screenOptions={{
                animation: 'fade',
                // headerShown: false,
                tabBarInactiveTintColor: '#999999',
                tabBarActiveTintColor: '#E6D39F',
            }}
        >
            <Tab.Screen name="HomePage"
                component={HomePage}
                options={{
                    headerShown: false,
                    title: '首页',
                    tabBarLabel: '首页',
                    tabBarAccessibilityLabel: '首页x',
                    tabBarIcon: ({ focused, color, size }) => {
                        return <Image
                                    source={ focused ? TabHomeSelect : TabHome }
                                    style={{ width: 30, height: 30 }}
                                />;
                    },
                    tabBarBadge: 3,
                }}
            />
            <Tab.Screen
                name="find"
                component={FindHome}
                options={{
                    tabBarLabel: '发现',
                    tabBarIcon: ({ focused, color, size }) => {
                        return focused ? <TabbarBtnHig width={size}/> : <TabbarBtnNor width={size} />;
                    },
                }}
            />
            <Tab.Screen name="MyHome" component={MyHome}
                options={{
                    title: '我的',
                    tabBarLabel: '我的',
                    tabBarAccessibilityLabel: '我的x',
                    tabBarIcon: ({ focused, color, size }) => {
                        return <Image
                                    source={ focused ? TabMySelect : TabMy }
                                    style={{ width: 30, height: 30 }}
                                />;
                    },
                }}
            />
        </Tab.Navigator>
    );
};

export default Layout;

const TabBar = (props = {} as any) => {
    const { state, descriptors, navigation } = props;

    return (
        <View style={styles.tabBarBox}>
            {state.routes.map((route: any, index: number) => {
                const { options } = descriptors[route.key];
                const label =
                    options.tabBarLabel !== undefined
                        ? options.tabBarLabel
                        : options.title !== undefined
                            ? options.title
                            : route.name;

                const isFocused = state.index === index;

                const onPress = () => {
                    const event = navigation.emit({
                        type: 'tabPress',
                        target: route.key,
                        canPreventDefault: true,
                    });

                    if (!isFocused && !event.defaultPrevented) {
                        navigation.navigate(route.name, route.params);
                    }
                };

                const onLongPress = () => {
                    navigation.emit({
                        type: 'tabLongPress',
                        target: route.key,
                    });
                };

                return (
                    <TouchableOpacity
                        key={'tabBar' + index}
                        accessibilityRole="button"
                        activeOpacity={1}
                        accessibilityState={isFocused ? { selected: true } : {}}
                        accessibilityLabel={options.tabBarAccessibilityLabel}
                        testID={options.tabBarTestID}
                        onPress={onPress}
                        onLongPress={onLongPress}
                        style={{ flex: 1 , justifyContent: 'center', alignItems: 'center' }}
                    >
                        <Text style={[
                            styles.tabBarBoxItemTxt,
                        ]}>
                            {label}
                        </Text>
                    </TouchableOpacity>
                );
            })}
        </View>
    );
};
const styles = StyleSheet.create({
    tabBarBox: {
        flexDirection: 'row',
        marginBottom: 40,
    },
    tabBarBoxItemTxt: {
        fontSize: 12,
    },
});
