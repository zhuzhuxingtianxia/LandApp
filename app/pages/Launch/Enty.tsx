/**
 * @description 启动界面控制
*/
import React, { useEffect, useMemo } from 'react';
import { useSelector } from '@utils/context';
import Guide from '@pages/MainPage/Guide';
import Main from '../Main';
import RootStack from './RootStack';
// import { Main as  MainConst, Auth } from './RouteConst';
import { AuthStack } from '../AuthPage/Screens';

const Enty = () => {
    
    const {token, userGuide} = useSelector((state: any) => state);

    const Page = useMemo(() => {
      let Com = <Guide />
      if(userGuide) {
        Com = token ? <RootStack />: <AuthStack />;
      }
      return Com;
    },[token, userGuide])

    return (
      // <RootStack />
      Page 
    )
}

export default Enty;