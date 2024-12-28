
// 创建一个会抛出错误的组件
const FailingComponent = () => {
    throw new Error('异常状态测试，显示错误提示组件');
};

export default FailingComponent;