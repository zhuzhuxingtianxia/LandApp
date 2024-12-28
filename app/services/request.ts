/**
 * @description 网络请求管理
*/
import { BASE_URL } from "@/config/host";
import axios from "axios";

/*
// 1. get
const res =  await Service.get(`/api/appConfig/listNew`, {
        params: params,
        headers: header
    });
// 2. post
    Service.post(`/api/appConfig/listNew`, {
        key: 'value',
    });
    // 3. 
    const res1 = await Service({
        method: 'get',
        url: '/api/appConfig/listNew',
        // data: {},
        params: params,
        headers: header
    })
*/

//1. 创建新的axios实例，
const service = axios.create({
    // 公共接口host
    baseURL: BASE_URL,
    // 超时时间 单位是ms，这里设置了60s的超时时间
    timeout: 60 * 1000,
});
// 2.请求拦截器
service.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8';
service.interceptors.request.use(config => {
    // 在发送请求之前做些什么，比如每个请求都带上token
    const header = {
        'version': '2.4.20',
        'channel': 'IOS'
    };
    config.headers = {
        ...header,
        ...config.headers, 
    } as any;
    console.log('=============')
    console.log(config);
    
    return config;
}, error => {
    // 对请求错误做些什么
    return Promise.reject({ info: error.message })
})

// 3.添加响应拦截器
service.interceptors.response.use(response => {
    return Promise.resolve(response.data);
}, error => {
    // 对响应错误做点什么
    return Promise.reject({ info: error.message })
})

//导出
export default service;