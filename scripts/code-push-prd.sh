#!/bin/bash 

#设置编码格式 utf-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 是否强制更新
ForceUpdate=true

# 环境变量 dev为开发环境，其他为生产环境
Env=$1

# 配置开发和生产的 accessKey
if test "$Env" = "dev"
then echo "----------------------------\n\n 准备发布测试环境热更新 \n\n-----------------------------";
AccessKey=8_lXbZm877dxUjCw3BTlTgavkmfeEJ9xRCg2be
CodePushURL=http://localhost:3000
else echo "=============================\n\n 准备发布生产环境热更新 \n\n==============================";
AccessKey=9Unt_UXrGGW_0NZGO4jarIiH42DIN184EY2aWl
CodePushURL=http://127.0.0.1:3000
fi

#进入项目所在目录，需安装npm
PROJECT_ROOT=$(npm prefix)

#获取热更新版本号bundleVersion 和更新描述bundleComment
APP_VERSION=$(node -p "require('./package.json').version")
BUNDLE_VERSION=$(node -p "require('./package.json').bundlePrdVersion")
BUNDLE_COMMENT=$(node -p "require('./package.json').bundlePrdComment")

echo "version: ${APP_VERSION} bundleVersion: ${BUNDLE_VERSION} bundleComment: ${BUNDLE_COMMENT}"
echo "$APP_VERSION.$BUNDLE_VERSION"

{
#判断codepush是否登录
LOGIN_NAME=`code-push-standalone whoami`
}||{
LOGIN_NAME='Error'
}
echo "LOGINNAME: ${LOGIN_NAME}";
if test "$LOGIN_NAME" = "Error"
then echo '未登录';
else echo '已登录';
code-push-standalone logout
fi
code-push-standalone login $CodePushURL --accessKey $AccessKey
code-push-standalone whoami

# 执行打包发布命令
if test "$Env" = "dev"
then echo "开始dev打包发布";
code-push-standalone release-react Hyx-ios ios \
    --deploymentName Staging \
    --mandatory $ForceUpdate \
    --targetBinaryVersion "$APP_VERSION" \
    --description "$BUNDLE_VERSION#$BUNDLE_COMMENT"

code-push-standalone release-react Hyx-android android \
    --deploymentName Staging \
    --mandatory $ForceUpdate \
    --targetBinaryVersion "$APP_VERSION" \
    --description "$BUNDLE_VERSION#$BUNDLE_COMMENT"

else echo "开始prod打包发布";
confirm() {
    echo -n "你确定要执行Production吗？(y/n): "
    read -n 1 -r response
    echo
    if [[ $response =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}
if confirm; then
code-push-standalone release-react Hyx-ios ios \
    --deploymentName Production \
    --mandatory $ForceUpdate \
    --targetBinaryVersion "$APP_VERSION" \
    --description "$BUNDLE_VERSION#$BUNDLE_COMMENT"

code-push-standalone release-react Hyx-android android \
    --deploymentName Production \
    --mandatory $ForceUpdate \
    --targetBinaryVersion "$APP_VERSION" \
    --description "$BUNDLE_VERSION#$BUNDLE_COMMENT"
else
    echo "操作已取消。"
fi

fi

echo "=========================\n\n  脚本执行完毕 \n\n=========================";