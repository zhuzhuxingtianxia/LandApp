import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { HostComponent, ViewProps } from 'react-native';
import type { BubblingEventHandler } from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import type React from 'react';

export interface NativeProps extends ViewProps {
  color?: string;
  // 定义事件方法,<T>其中参数T必须是一个对象
  onWillShow?: BubblingEventHandler<{flag?: string}> | null;
}

// 定义ref调用方法
interface NativeCommands {
  reload: (viewRef: React.ElementRef<HostComponent<NativeProps>>, option?: string) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['reload'],
});

export default codegenNativeComponent<NativeProps>('MyView') as HostComponent<NativeProps>;
