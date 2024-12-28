

import React, { useEffect } from "react";
import Layout from "./TabLayout";
import { MyCodePush } from "@/utils/MyCodePush";

const Main = () => {

    useEffect(() => {
        MyCodePush();
    },[])

    return (
        <>
            <Layout />
            {/* 全局弹框处理 */}
        </>
    )
}

export default Main;