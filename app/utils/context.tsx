import React, { createContext, useEffect, useReducer } from 'react';

const RootContext = createContext({});

// 如何模块化处理???
const createReducer = (
    name: string,
    initialState: any,
    reducers: {[key: string]:Function}
) => {
    const { state } = React.useContext<any>(RootContext);
    state[name] = initialState;
    return {
        state: state,
        reducer: (state = initialState, action: { type: string, payload: any }) => {
            const { type, payload } = action;
            const reducer = reducers[type];
            return reducer ? reducer(state, payload) : state;
        }
    }
}

// 创建提供者组件
const reducer = (state: any, action: { type: string, payload: any }) => {
    return { ...state, ...action.payload }
};

export const Provider = ({ children }: any) => {
    const [state, dispatch] = useReducer(reducer, {});

    useEffect(() => {
        // 当状态变化时，执行这个回调函数
        console.log('State changed:', state);
    }, [state]);

    return (
        <RootContext.Provider value={{ state, dispatch }}>
            {children}
        </RootContext.Provider>
    );
};

export const useSelector = (selector: Function) => {
    const { state } = React.useContext<any>(RootContext);
    return selector(state);
}

export const useDispatch = () => {
    const { dispatch } = React.useContext<any>(RootContext);
    return dispatch;
}