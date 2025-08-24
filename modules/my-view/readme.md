# 自定义view组件
新架构自定义view组件：`react-native-my-view`

## 安装
```bash
yarn add link:./modules/my-view
// 
"react-native-my-view": "link:./modules/my-view",
```

## 使用
```jsx
import { MyView } from 'react-native-my-view';

<MyView
  style={{
    width: 100,
    height: 100,
    backgroundColor: 'red',
  }}
/>
```
其他用法：
```
<MyView
  style={{ width: 100, height: 100 }}
  color="#FF0"
  ref={myRef}
  onWillShow={e=> {
    // 获取参数
    const { flag } = e.nativeEvent;
    console.log('onWillShow:', flag);
    // 调用原生方法
    myRef.current?.reload?.('xxxx');
  }}
>
  <Text style={{ backgroundColor: 'red' }}>123344556</Text>
</MyView>
```

## Codegen
将Codegen规范文件放在了fabric文件夹下，需要修改`package.json`->`codegenConfig`->`jsSrcsDir`指向的路径。