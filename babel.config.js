
//路径别名配置
const aliasConfig = {
  root: ['./'],
  alias: {
    '@': './app',
    '@components': './app/components',
    '@pages': './app/pages',
    '@utils': './app/utils',
    '@assets': './app/assets',
    // '@styles': './app/styles',
    // '@config': './app/config',
    // '@hooks': './app/hooks',
    '@services': './app/services',
  }
}

module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    ['module-resolver', aliasConfig],
    ['import', { libraryName: '@ant-design/react-native' }],
    // 这个需要放在最后
    'react-native-reanimated/plugin',
  ],
};
