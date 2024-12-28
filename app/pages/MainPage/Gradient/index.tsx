import React from 'react';
import { View, StyleSheet, Text } from 'react-native';
import LinearGradient from 'react-native-linear-gradient';


const Gradient = () => {
    const colors = ['red', 'green', 'blue'];
    return (
        <View style={{ flex: 1 }}>
            <View style={styles.container}>
                {colors.map((value, index) => (
                    <LinearGradient
                        colors={[value, 'white']}
                        key={index}
                        style={styles.gradient}
                    />
                ))}
            </View>
            <LinearGradient colors={['#4c669f', '#3b5998', '#192f6a']} style={styles.linearGradient}>
                <Text style={styles.buttonText}>
                    Sign in with Facebook
                </Text>
            </LinearGradient>
        </View>

    );
};

export const styles = StyleSheet.create({
    container: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'space-between',
    },
    gradient: {
        height: 100,
        margin: 4,
        width: 100,
    },
    rightContainer: {
        flex: 1,
        marginLeft: 12,
        paddingVertical: 8,
    },
    linearGradient: {
        marginTop: 15,
        paddingLeft: 15,
        paddingRight: 15,
        borderRadius: 5
      },
      buttonText: {
        fontSize: 18,
        fontFamily: 'Gill Sans',
        textAlign: 'center',
        margin: 10,
        color: '#ffffff',
        backgroundColor: 'transparent',
      },
});

export default Gradient;