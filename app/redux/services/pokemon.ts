import { createApi, fetchBaseQuery, retry } from '@reduxjs/toolkit/query/react'
import { BASE_URL } from "@/config/host";

const fetchFn = async (request: string | URL | Request, config: RequestInit | undefined) => {
  const response = await fetch(request, config);
  
  if(__DEV__) {
    const res = response.clone();
    const json = await res.json();
    console.log('URL:', (request as Request).url);
    console.log('Method:', (request as Request).method);
    console.log('response:', json);
  }
  
  if (response.ok) {
    return response;
  } else {
    throw new Error(response.statusText)
  }
}

const baseServiceQuery = fetchBaseQuery({
  baseUrl: BASE_URL,
  prepareHeaders: (headers, { getState }) => {
    const header = {
        'Content-Type': 'application/json',
        'version': '2.4.20',
        'channel': 'IOS'
    } as {[key: string]: any};
    Object.keys(header).forEach(key => {
        headers.set(key, header[key]);
    });
    const { auth } = getState() as any;
    if (auth && auth.token) {
      if (!headers.has('authorization')) {
        headers.set('authorization', `Bearer ${auth.token}`)
      }
    }
    return headers
  },
  // responseHandler: async (res) => {
  //   // 如果此处与query下都实现responseHandler，则query下的responseHandler优先级更高
  //   const result = await res.json();
  //   return result;
  // }
  fetchFn: fetchFn
})


const baseServiceQueryRetry = retry(baseServiceQuery, { maxRetries: 3 });

// 返回值类型
type Pokemon = {
    name: string
}
// 参数
type IParams = {
    type: string,
    version: string,
    build: string,
    channel: string,
    mobile?:string,
    token?:string
}
// Define a service using a base URL and expected endpoints
export const pokemonApi = createApi({
  reducerPath: 'listNewApi',
  baseQuery: baseServiceQueryRetry,
  tagTypes: ['Pokemon'],
  endpoints: (builder) => ({
    getAppConfig: builder.query<Pokemon, any>({
      providesTags: ['Pokemon'],
      // forceRefetch(params) {
      //   // 根据条件判断是否需要强制重新获取数据
      //   return true;
      // },
      query: (params) => ({
        url: `/api/appConfig/listNew`,
        method: 'GET',
        params: params,
        // responseHandler: async (res: any) => {
        //   debugger
        //   const result = await res.json();
        //   return result;
        // },
      }),
      // queryFn: async (arg, queryApi, extraOptions, baseQuery) => {
      //   const { data } = await baseQuery(arg);
      //   return {data: data}
      // },
      onCacheEntryAdded: async (arg, { updateCachedData, cacheDataLoaded }) => {
        console.log('Cache entry added');
        // await cacheDataLoaded;
        // const data = arg.originalArgs.queryArg;
        // updateCachedData
      }
    }),
    addAppConfig: builder.mutation<Pokemon, IParams>({
      query: (params) => ({
        url: `/api/appConfig/listNew`,
        method: 'POST',
        // params: params,
        body: params,
      }),
      invalidatesTags: (result, error, arg, meta)=> {
        if (error) {
          return []
        }
        return [{ type: 'Pokemon' }]
      },
    }),
    uploadFile: builder.mutation<{ url: string }, { file: File }>({
      query: ({file}) => {
        const formData = new FormData()
        formData.append('file', file)
        return {
          url: '/common/upload',
          method: 'POST',
          body: formData,
        }
      }
    })
  }),
})

// Export hooks for usage in functional components, which are
// auto-generated based on the defined endpoints
export const { 
  useGetAppConfigQuery, 
  useAddAppConfigMutation,
  useUploadFileMutation
} = pokemonApi

/*
  import { skipToken } from '@reduxjs/toolkit/query/react';

  // 这将跳过缓存
 const { data, error, isLoading } = useGetPostsQuery(skipToken);

 // 结构的对象
 const [addAppConfig, { isLoading: isAdding }] = useAddAppConfigMutation();

*/