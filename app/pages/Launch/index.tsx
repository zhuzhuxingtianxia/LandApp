import React, { useMemo, Suspense, useEffect, useReducer } from 'react';
import { Provider } from '@utils/context';
import RootStack from './RootStack';
import { ActivityIndicator, View } from 'react-native';
import Enty from './Enty';

const Launch = () => {

  return (
    <Provider>
      <Suspense fallback={<Loading />}>
          <Enty />
      </Suspense>
    </Provider>
  )
}

function Loading() {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <ActivityIndicator size="large" color="#0000ff" />
    </View>
  );
}

export default Launch;