

const Hosts = {
    test: 'https://app-uat.gkewang.com',
    stg: 'https://app-uat.gkewang.com',
    prd: 'https://app-uat.gkewang.com',
} as any;
const env: string = (global as any).env || 'test';
// /api/appConfig/listNew
export const BASE_URL = Hosts[env];