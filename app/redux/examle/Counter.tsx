import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import type { RootState } from '@/redux/store';
import { useSelector, useDispatch } from 'react-redux';
import { decrement, increment, incrementByAmount } from '../slice/counterSlice';

export function Counter() {
  const count = useSelector((state: RootState) => state.counter.value)
  const dispatch = useDispatch()

  return (
    <View style={styles.content}>
        <Text style={styles.txt}>{count}</Text>
        <View style={styles.box}>
            <TouchableOpacity onPress={() => dispatch(increment())}>
                <Text style={styles.action}>加+</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => dispatch(decrement())}>
                <Text style={styles.action}>减-</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => dispatch(incrementByAmount(10))}>
                <Text style={styles.action}>加+10</Text>
            </TouchableOpacity>
        </View>
        
    </View>
  )
}

const styles = StyleSheet.create({
    content: {
        alignItems: 'center',
        justifyContent: 'center',
    },
    txt: {
        fontSize: 18,
        color: '#22385A',
    },
    box: {
        marginTop: 20,
        flexDirection: 'row'
    },
    action: {
        color: '#0C59FF',
        marginHorizontal: 10
    }
})