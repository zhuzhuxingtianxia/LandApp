
## codegen脚本
生成iOS代码

```
cd TurboTest1
# 使用软连接的方式添加依赖 yarn 使用link, npm使用file
yarn add link:./modules/RNCalculator
cd ios
rm -rf build & bundle exec pod install
```

* targetPlatform: 目标平台。支持的值：`android`, `ios`, `all`。默认值是 `all`
* path: `package.json`的路径,默认路径是当前工作目录。path指向根目录的`package.json`时执行上面的脚本同时会自动执行相关依赖`package.json`的`codegenConfig`配置。
* outputPath: 输出路径。默认值是 `codegenConfig.outputDir` 中定义的值。

当使用Codegen生成脚手架代码时，iOS不会自动清理构建文件夹。如果更改了规范名称，需要先删除build文件夹，然后重新运行Codegen脚本。

生成android代码
```
// 如果已添加可忽略此步骤
yarn add ./modules/RNCalculator
cd android
./gradlew generateCodegenArtifactsFromSchema
// 设置android/gradle.properties文件的newArchEnabled=true
node ./node_modules/react-native/scripts/generate-codegen-artifacts.js \
  --targetPlatform android \
  --path ./ \
  --outputPath ./node_modules/rn-calculator/android/build/generated/source/codegen/
```

## 使用工具
```
npx create-react-native-library@latest module-name
```
* 询问是否创建本地库，选择`y`
* 指定库的位置默认在项目根目录创建`modules`文件夹
* 设置npm包的名称，默认会加上`react-native-`前缀，例如`react-native-module-name`可以改为`module-name`
* 设置包的描述，随便设置后面可以修改
* 库类型：
  * JavaScript library - supports Expo Go and Web
  * Native module - bridge for native APIs to JS
  * Native view - bridge for native views to JS
  * Turbo module with backward compat - supports new arch (experimental)
  * Turbo module - requires new arch (experimental)
  * Fabric view with backward compat - supports new arch (experimental)
  * Fabric view - requires new arch (experimental)
这里我们选择`Turbo module - requires new arch (experimental)`的方式
然后选择想要的语言：
* Kotlin & Objective-C
* C++ for Android & iOS
选择第一个。
运行脚本后，会在`modules`文件夹下自动生成一个名为`module-name`的文件夹:
* `package.json`: 文件中包含`codegenConfig`字段，用于配置Codegen及说明。
* `src`: 文件夹中声明定义需要的规范。
* `android`: 文件夹中包含Android平台相关的代码。
* `ios`: 文件夹中包含iOS平台相关的代码。
* `podspec`: 文件中包含iOS平台pods相关的配置。
* `react-native.config.js`: 文件中配置Android平台cmake相关。

```
cd TurboTest1
# 使用软连接的方式添加依赖 yarn 使用link, npm使用file。之后会在iOS项目下生成build文件夹
yarn add link:./modules/RNCalculator

```
在ios/andriod下编写原生代码
```
cd ios
rm -rf build & bundle exec pod install
```

使用:
```
import NativeLocalStorage from 'NativeLocalStorage/spec/NativeLocalStorage';
import RNCalculator from "rn-calculator";
import { multiply } from 'module-name';
```