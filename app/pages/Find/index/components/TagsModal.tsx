/* eslint-disable react-native/no-inline-styles */
/**
 * @description 客户标签
*/

import { Input, Modal, Text, View } from '@ant-design/react-native';
import React, { memo, useEffect } from 'react';
import { Image, StyleSheet, TextInput, TouchableOpacity } from 'react-native';
import IconClose from '@/assets/icon/close.png';
import icon_del from '@/assets/icon/icon_del.png';
import { fontStyle } from '@/utils';
import { HighlightText } from '@/components/HighlightText';

export const TagColors = ['#916E6E', '#6E918B', '#726E91', '#91866E', '#959595', '#55789B'];

const LimitMaxLength = 10;

interface TagsModalProps {
  visible: boolean;
  tags: string[];
  onClose?: () => void;
  onTagChange?: (tags: string[]) => void;
}
const isShake = true;
const TagsModal = (p: TagsModalProps) => {

  const [inputValue, setInputValue] = React.useState('');
  const inputValueRef = React.useRef<TextInput>(null);

  useEffect(() => {
    if (p.visible) {
      setInputValue('');
    }
  }, [p.visible]);
  const onClosePress = () => {
    p.onClose?.();
  };

  const onDeleteTag = (index: number) => {
    const newTags = [...p.tags];
    newTags.splice(index, 1);
    p.onTagChange?.(newTags);
  };

  const onAddTag = ()=> {
    if (inputValue.trim() === '') {
      return;
    }
    const newTags = [...p.tags, inputValue.trim()];
    p.onTagChange?.(newTags);
    setInputValue('');
  };

  return (
    <Modal
      visible={p.visible}
      popup={true}
      maskClosable
      onClose={onClosePress}
      animationType="slide-up"
      style={styles.popupContainer}
      bodyStyle={styles.flex}
      onRequestClose={() => {
        //  Android 在后退按键时触发，返回true时阻止BackHandler事件
        return false;
      }}
    >
      <View style={styles.titleHeader}>
        <Text style={styles.title}>客户标签</Text>
        <TouchableOpacity
          activeOpacity={0.8}
          onPress={onClosePress}
        >
          <Image style={styles.icon_close} source={IconClose} />
        </TouchableOpacity>
      </View>
      <View style={styles.flex}>
        <View style={styles.tagBox}>
          {
            p.tags.length > 0 ?
              p.tags.map((tag, index) => {
                return (
                  <View key={index} style={[
                    styles.tagItem,
                    { backgroundColor: TagColors[index % TagColors.length] },
                  ]}>
                    <Text style={styles.tagText}>{tag}</Text>
                    <TouchableOpacity onPress={()=>onDeleteTag(index)}>
                      <Image source={icon_del}/>
                    </TouchableOpacity>
                  </View>
                );
              })
              : null
          }
        </View>
        <View style={{ paddingHorizontal: 20, marginTop: 40 }}>
          <Text style={styles.label}>新增标签</Text>
          <View style={styles.inputBox}>
            {/* 若使用Input 存在闪烁问题使用TextInput 替换 */}
            {
              isShake ? <Input style={styles.flex}
                inputStyle={styles.inputStyle}
                placeholder="请输入标签内容"
                // value={inputValue}
                maxLength={LimitMaxLength}
                onChangeText={(text)=>{
                  setInputValue(text);
                }}
                showCount={{
                  formatter: ({ count, maxLength }) => {
                    return <HighlightText style={{ ...fontStyle(10,'#999'), marginRight: 15 }}>
                      {`${count}/${maxLength}`}
                    </HighlightText> as React.ReactNode;
                  },
                }}
              /> :
              <>
              <TextInput style={styles.inputStyle}
                ref={inputValueRef}
                underlineColorAndroid="transparent"
                keyboardType="default"
                returnKeyType="done"
                placeholder="请输入标签内容"
                onChangeText={(text)=>{
                  console.log(text);
                  setInputValue(text);
                }}
                onBlur={()=>{
                  const tagText = inputValue.trim().length > LimitMaxLength ? inputValue.trim().slice(0, LimitMaxLength) : inputValue.trim();
                  setInputValue(tagText);
                  inputValueRef.current?.setNativeProps({ text: tagText });
                }}
              />
              <View>
              <HighlightText style={{
                  ...fontStyle(10,'#999'),
                  marginRight: 15,
                  color: inputValue.length > LimitMaxLength ? 'red' : '#999',
                }}>
                  {`${inputValue.length}/${LimitMaxLength}`}
                </HighlightText>
              </View>
              </>
            }
            <TouchableOpacity activeOpacity={0.8}
              disabled={inputValue.length === 0}
              style={[styles.addbtn, inputValue.length === 0 ? { backgroundColor: '#DDD' } : {}]}
              onPress={onAddTag}
            >
              <Text style={fontStyle(12, '#fff')}>添加</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  popupContainer: {
    height: '90%',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
  },
  flex: {
    flex: 1,
  },
  titleHeader: {
    height: 65,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  title: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#000',
  },
  icon_close: {
    width: 30,
    height: 30,
  },
  tagBox: {
    marginTop: 10,
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    paddingHorizontal: 15,
  },
  tagItem: {
    flexDirection: 'row',
    height: 40,
    borderRadius: 20,
    paddingHorizontal: 10,
    gap: 5,
    alignItems: 'center',
  },
  tagText: {
    ...fontStyle(12, '#FFF'),
  },
  label: {
    ...fontStyle(12, 'rgba(0, 0, 0, 0.50)'),
    marginBottom: 10,
  },
  inputBox: {
    flexDirection: 'row',
    alignItems: 'center',
    height: 50,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#E9E9EC',
    boxShadow: '0px 10px 10px 0px rgba(0,0,0,0.02)',
  },
  inputStyle: {
    flex: 1,
    paddingHorizontal: 15,
    fontSize: 12,
  },
  addbtn: {
    width: 70,
    marginTop: -1,
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#9F0000',
    borderTopRightRadius: 10,
    borderBottomRightRadius: 10,
  },
});

export default memo(TagsModal);
