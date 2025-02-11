
/**
 * @description 搜索文本关键字高亮组件
*/
import React from 'react';
import type { TextProps, TextStyle } from 'react-native';
import { StyleSheet, Text } from 'react-native';
const styles = StyleSheet.create({
  normal: {
    fontFamily: 'Montserrat-Regular',
  },
  bold: {
    fontFamily: 'Montserrat-SemiBold',
  },
});

interface HighlightTextProps extends TextProps {
    children: string | number | undefined;
    keyword?: string;
    highlightColor?: string;
}

const HighlightText = (props: HighlightTextProps) => {
const { keyword, highlightColor = '#9F0000' } = props;
// 关键字拆分
const keywordSplit = (text?: string) => {
    if (!text || !keyword) {return splitLetterAndNumber(text);}
    const keywordReg = new RegExp(`(${keyword})`, 'gi');
    const splitText = text.split(keywordReg);
    return splitText.map((item, index) => {
    if (keywordReg.test(item)) {
        return (
        <Text
            key={index}
            style={[props.style, { color: highlightColor }]}
        >
            {splitLetterAndNumber(item, true)}
        </Text>
        );
    }
    return splitLetterAndNumber(item);
    });
};
const mergeStyles = (...styles: TextStyle[]) => ({
    // 使用 Object.assign 或者 扩展运算符 来合并所有样式对象
    ...styles.reduce((accumulator, currentStyle) => ({
    ...accumulator,
    ...currentStyle,
    }), {}),
});

// 判断字符串是否加粗
const isBold = (style?: TextStyle) => {
    if (!style) {return false;}
    let styleObject = style;
    if(Array.isArray(style)){
    styleObject = mergeStyles(...style);
    }
    const fontWeight = styleObject.fontWeight;
    // 判断是否为加粗
    if(fontWeight){
    if (typeof fontWeight === 'string' && fontWeight.toLowerCase().includes('bold')) {
        return true;
    }else if (Number(fontWeight) >= 500) {
        return true;
    }
    }
    return false;
};

// 拆分字符串中的英文字母或数字
const splitLetterAndNumber = (text?: string, isKeyword = false) => {
    if (!text) {return text;}
    const letterAndNumberReg = /([a-zA-Z0-9]+)/g;
    const splitText = text.split(letterAndNumberReg);
    return splitText.map((item, index) => {
    if (letterAndNumberReg.test(item)) {
        return (
        <Text
            key={index}
            style={[
            props.style,
            isBold(props.style as TextStyle) ? styles.bold : styles.normal,
            isKeyword && { color: highlightColor },
            ]}
        >
            {item}
        </Text>
        );
    }
    return item;
    });
};

return (
    <Text {...props} >
    {keywordSplit(String(props.children ?? ''))}
    </Text>
);
};

export { HighlightText };
