/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {
	SafeAreaView,
	useColorScheme,
} from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import codePush from "react-native-code-push";
import { navigationRef } from '@/pages/Launch/Navigation';
import { Colors,} from 'react-native/Libraries/NewAppScreen';
import AppProvider from '@/utils/AppProvider';
import Launch from '@/pages/Launch';
import ErrorBoundary from '@/components/ErrorBoundary';

const codePushOptions = { checkFrequency: codePush.CheckFrequency.MANUAL };

function App(): React.JSX.Element {
	const isDarkMode = useColorScheme() === 'dark';
	const backgroundStyle = {
		backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
	};

	return (
		<SafeAreaProvider>
			<NavigationContainer 
				ref={navigationRef}
				// initialState={}
				// linking={}
				onReady={()=>{
					console.log('Navigation container is ready')
				}}
				// onStateChange={(state) => console.log('New state is', state)}
			>
				<ErrorBoundary>
					<AppProvider>
						<Launch />
					</AppProvider>
				</ErrorBoundary>
			</NavigationContainer>
		</SafeAreaProvider>
	);
}

export default codePush(codePushOptions)(App);
