import React from 'react'
import { Provider } from '@ant-design/react-native';
import zhCN from '@ant-design/react-native/lib/locale-provider/zh_CN';
import { Provider as ReduxProvider } from 'react-redux';
import dayjs from 'dayjs';
import 'dayjs/locale/zh-cn';
import { store } from '@/redux/store';

dayjs.locale('zh-cn')

const AppProvider = (props: {children: React.JSX.Element}) => {
  return (
    <ReduxProvider store={store}>
      <Provider locale={zhCN}>{props.children}</Provider>
    </ReduxProvider>
  )
}

export default AppProvider;