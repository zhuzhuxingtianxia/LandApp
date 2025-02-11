/* eslint-disable @typescript-eslint/no-invalid-void-type */
import React, { isValidElement, useEffect } from 'react';
import { Portal, Modal } from '@ant-design/react-native';
import type { TextStyle, ViewStyle } from 'react-native';
import { View, Text, StyleSheet, Image, TouchableOpacity, ScrollView } from 'react-native';
import { fontStyle, rpx, ScreenWidth } from '@/utils';
import IconClose from '@/asserts/common/close.png';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

interface Action<T = TextStyle> {
  text: string
  onPress?: () => void | Promise<unknown>
  style?: T | undefined
}

interface AntAlertProps {
  title?: string | React.ReactNode,
  content?: string | React.ReactNode,
  actions?: Action<TextStyle>[],
  onBackHandler?: ()=>boolean,
  style?: ViewStyle;
  bodyStyle?: ViewStyle;
}

const Alert = (props: AntAlertProps) => {

  const key = Portal.add(
    <AlertContainer
      title={props.title}
      content={props.content}
      style={props.style}
      bodyStyle={props.bodyStyle}
      actions={props.actions}
      onAnimationEnd={(visible: boolean) => {
        if (!visible) {
          Portal.remove(key);
        }
      }}
      onBackHandler={()=>{
        if (props.onBackHandler) {
          return props.onBackHandler();
        }
        return true;
      }}
    />,
  );
  return key;
};

Alert.hide = (key: number) => {
  Portal.remove(key);
};

interface AlertContainerProps extends AntAlertProps {
  content: React.ReactNode,
  onBackHandler: ()=>boolean,
  onAnimationEnd?: (visible: boolean) => void
}

const AlertContainer = (props: AlertContainerProps) => {
  const { onAnimationEnd } = props;
  const [visible, setVisible] = React.useState(true);

  useEffect(() => {
  },[]);

  const onBackAndroid = () => {
    const { onBackHandler } = props;
    if (typeof onBackHandler === 'function') {
      const flag = onBackHandler();
      if (flag) {
        onClose();
      }
      return flag;
    }
    if (visible) {
      onClose();
      return true;
    }
    return false;
  };
  const onClose = () => {
    setVisible(false);
  };

  const contentView = ()=> {
    return (
      <View style={[styles.modal, props.style]}>
        {
          props.title &&
          <View style={styles.titleView}>
            <View>
              {
                isValidElement(props.title) ? props.title : <Text style={styles.titleText}>{props.title}</Text>
              }
            </View>
            <TouchableOpacity
              activeOpacity={0.8}
              onPress={onClose}
            >
              <Image style={styles.closeIcon} source={IconClose}/>
            </TouchableOpacity>
          </View>
        }
        <View style={[styles.content, props.bodyStyle]}>
          { isValidElement(props.content) ? props.content : <Text style={[styles.contentText, props.actions && props.actions.length > 0 ? {} : { marginBottom: rpx(25) }]}>{props.content}</Text> }
        </View>
        {
          props.actions && props.actions.length > 0 &&
          <View style={styles.actions}>
            {
              props.actions?.map((item, index) => {
                return (
                  <TouchableOpacity
                    key={index}
                    style={[
                      styles.button,
                      index === (props.actions as Action[]).length - 1 ? styles.buttonLight : styles.buttonCancel,
                      item.style,
                    ]}
                    activeOpacity={0.8}
                    onPress={() => {
                      const orginPress = item.onPress || function () {};
                      const res = orginPress();
                      if (res && res.then) {
                        res.then(() => {
                          onClose();
                        });
                      } else {
                        onClose();
                      }
                    }}
                  >
                    <Text style={[styles.btnText, textStyle(item.style as TextStyle)]}>{item.text}</Text>
                  </TouchableOpacity>
                );
              })
            }
          </View>
        }
      </View>
    );
  };

  const propsWidth = React.useMemo(() => {
    if(props.style && props.style.width) {
      return { with: props.style.width };
    }
    return {};
  },[props.style]);

  const textStyle = (style: TextStyle) => {
    if(style) {
      const _style: TextStyle = {};
      if (style.fontSize) {
        _style.fontSize = style.fontSize;
      }
      if (style.color) {
        _style.color = style.color;
      }
      if (style.fontWeight) {
        _style.fontWeight = style.fontWeight;
      }
      return _style;
    }
    return {};
  };

  return (
    <Modal
      transparent
      visible={visible}
      onAnimationEnd={onAnimationEnd}
      onRequestClose={onBackAndroid}
      styles={{
        innerContainer: { ...styles.innerContainer, ...propsWidth },
      }}
      bodyStyle={styles.modalBody}>
      <ScrollView >
        {contentView()}
      </ScrollView>
    </Modal>
  );

};

const styles = StyleSheet.create({
  innerContainer: {
    width: ScreenWidth - rpx(40),
    paddingTop: 0,
    backgroundColor: 'transparent',
  },
  modalBody: {
    paddingHorizontal: 0,
    paddingBottom: 0,
  },
  modal: {
    backgroundColor: '#fff',
    borderRadius: 20,
    paddingHorizontal: 20,
  },
  titleView: {
    height: 66,
    flexDirection: 'row',
    borderBottomColor: '#EFF0F4',
    borderBottomWidth: 0.5,
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  titleText: {
    fontSize: 16,
    fontWeight: 600,
    color: '#000',
  },
  closeIcon: {
    width: 30,
    height: 30,
  },
  content: {
    alignItems: 'center',
    paddingTop: 20,
  },
  contentText: {
    fontSize: 14,
    lineHeight: 28,
    color: '#000',
    fontWeight: 500,
  },
  actions: {
    gap: 15,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingBottom: 25,
    paddingTop: 28,
  },
  button: {
    flex: 1,
    height: 50,
    borderRadius: 16,
    borderWidth: 0,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonCancel: {
    backgroundColor: '#999',
    boxShadow: '0 5 5 0 rgba(153, 153, 153, 0.3)',
  },
  btnText: {
    fontSize: 14,
    fontWeight: 600,
    color: '#fff',
  },
  buttonLight: {
    backgroundColor: '#9F0000',
    boxShadow: '0 5 5 0 rgba(159, 0, 0, 0.1)',
  },
});
interface ActionSheetProps {
  title?: string | React.ReactNode,
  options?: string[],
  optionStyle?: TextStyle,
  onAction?: (index: number) => void,
}
const ActionSheet = (props: ActionSheetProps) => {
  const key = Portal.add(
    <ActionSheetView {...props}
      onAnimationEnd={(v)=>{
        if (!v) {
          Portal.remove(key);
        }
      }}
    />,
  );
  return key;
};

const ActionSheetView = (props: ActionSheetProps & {onAnimationEnd: (b: boolean) => void}) => {
  const { onAnimationEnd } = props;
  const insets = useSafeAreaInsets();
  const [visible, setVisible] = React.useState(true);
  const onBackAndroid = () => {
    if (visible) {
      onClosePress();
      return true;
    }
    return false;
  };
  const onClosePress = () => {
    setVisible(false);
  };
  return (<Modal
    popup={true}
    visible={visible}
    maskClosable
    onClose={onClosePress}
    animationType="slide-up"
    style={sheetStyles.popConteiner}
    // bodyStyle={styles.flex}
    onAnimationEnd={onAnimationEnd}
    onRequestClose={onBackAndroid}
  >
    <View style={{ paddingBottom: 10 + insets.bottom }}>
      <Text style={sheetStyles.titleText}>{props.title}</Text>
      {
        props.options?.map((option,k)=> {
          return (
            <TouchableOpacity key={k}
              style={sheetStyles.optionBox}
              activeOpacity={0.8}
              onPress={()=>props.onAction?.(k)}
            >
              <Text style={[sheetStyles.optionText, props.optionStyle]}>{option}</Text>
            </TouchableOpacity>
          );
        })
      }
    </View>
  </Modal>
  );
};

const sheetStyles = StyleSheet.create({
  popConteiner: {
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingHorizontal: 20,
  },
  titleText: {
    ...fontStyle(12,'#999'),
    textAlign: 'center',
    paddingVertical: 12,
    borderBottomColor: '#EFF0F4',
    borderBottomWidth: 0.5,
  },
  optionBox: {
    height: 60,
    justifyContent: 'center',
    borderBottomColor: '#EFF0F4',
    borderBottomWidth: 0.5,
  },
  optionText: {
    ...fontStyle(14),
    textAlign: 'center',
  },
});

export {
  Alert,
  ActionSheet,
};
