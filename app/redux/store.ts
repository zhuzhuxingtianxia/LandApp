/**
 * @description Redux store
*/
import { configureStore, Middleware } from '@reduxjs/toolkit';
import { setupListeners } from '@reduxjs/toolkit/query';
import { TypedUseSelectorHook, useDispatch, useSelector } from 'react-redux';
import { counterSlice } from './slice/counterSlice';
import { pokemonApi } from './services/pokemon'

const __DEV__ = process.env.NODE_ENV === 'development';

function setupStore() {
    const devMiddlewares: Middleware[] = []
    const prodMiddlewares: Middleware[] = []
    const apiMiddlewares: Middleware[] = [
        pokemonApi.middleware,
        // authApi.middleware,
        // userApi.middleware,
        // mainApi.middleware,
        // appApi.middleware,
        // designApi.middleware,
        // uploadApi.middleware,
    ]
    const store = configureStore({
        reducer: {
            counter: counterSlice.reducer,
            [pokemonApi.reducerPath]: pokemonApi.reducer,
            // [authApi.reducerPath]: authApi.reducer,
            // [userApi.reducerPath]: userApi.reducer,
            // [mainApi.reducerPath]: mainApi.reducer,
            // [appApi.reducerPath]: appApi.reducer,
            // [designApi.reducerPath]: designApi.reducer,
            // [uploadApi.reducerPath]: uploadApi.reducer,
            // [authSlice.name]: authSlice.reducer,
        },
        middleware: (getDefaultMiddleware) => {
            if (__DEV__) {
                return getDefaultMiddleware().concat(
                    ...apiMiddlewares,
                    ...devMiddlewares,
                    ...prodMiddlewares
                )
            }
            return getDefaultMiddleware().concat(
                ...apiMiddlewares,
                ...prodMiddlewares
            )
        },
    })

    // setUp refetchOnFocus and refetchOnReconnect
    setupListeners(store.dispatch)

    return store
}

const store = setupStore();
export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch
export const useAppDispatch = () => useDispatch<AppDispatch>()
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector

export { store };