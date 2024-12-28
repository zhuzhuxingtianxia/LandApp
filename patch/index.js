
/**
 * @description yarn 或npm install 后会执行该文件, 用于修复库存在的问题
 * 
*/
const Patchs = require('./patch').Patchs;
const path = require('path');
const fs = require('fs-extra');
const {spring} = require('./scripts/react-spring-scrollview-fix');
// spring();

Object.keys(Patchs).forEach(function(key) {
    var file = Patchs[key];
    var sourcePath = path.join(__dirname, file.source);
    var targetPath = path.join(__dirname, file.target);
    console.log(`Coping File From "${sourcePath}" To "${targetPath}"`);
    fs.copyFile(sourcePath, targetPath, function(err) {
        if (err) {
            throw err;
        } else {
            console.log('Copy File Success!');
        }
    });
});