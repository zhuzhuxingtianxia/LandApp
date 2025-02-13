import { useState } from 'react';
import { request, check, PERMISSIONS, RESULTS, checkNotifications, requestNotifications } from 'react-native-permissions';
import { Platform } from 'react-native';

type RequestType = 'request' | 'check' | undefined

const usePermissions = () => {
  const [hasMicrophonePermission, setHasMicrophonePermission] = useState(false);
  const [hasCameraPermission, setHasCameraPermission] = useState(false);
  const [hasLocationPermission, setHasLocationPermission] = useState(false);
  const [hasPhotoLibraryPermission, setHasPhotoLibraryPermission] = useState(false);
  const [hasNotificationPermission, setHasNotificationPermission] = useState(false);
  const [hasCalendarPermission, setHasCalendarPermission] = useState(false);

  const checkAndRequestMicrophonePermission = async (method:RequestType = 'request') => {
    const permission = Platform.select({
      ios: PERMISSIONS.IOS.MICROPHONE,
      android: PERMISSIONS.ANDROID.RECORD_AUDIO,
    });

    if (permission) {
      let result;
      if (method === 'check') {
        result = await check(permission);
      } else {
        result = await request(permission);
      }
      setHasMicrophonePermission(result === RESULTS.GRANTED);
      return result === RESULTS.GRANTED;
    }
  };

  const checkAndRequestCameraPermission = async (method:RequestType = 'request') => {
    const permission = Platform.select({
      ios: PERMISSIONS.IOS.CAMERA,
      android: PERMISSIONS.ANDROID.CAMERA,
    });

    if (permission) {
      let result;
      if (method === 'check') {
        result = await check(permission);
      } else {
        result = await request(permission);
      }
      setHasCameraPermission(result === RESULTS.GRANTED);
      return result === RESULTS.GRANTED;
    }
  };

  const checkAndRequestLocationPermission = async (method:RequestType = 'request') => {
    const permission = Platform.select({
      ios: PERMISSIONS.IOS.LOCATION_WHEN_IN_USE,
      android: PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION,
    });

    if (permission) {
      let result;
      if (method === 'check') {
        result = await check(permission);
      } else {
        result = await request(permission);
      }
      setHasLocationPermission(result === RESULTS.GRANTED);
      return result === RESULTS.GRANTED;
    }
  };

  const checkAndRequestPhotoLibraryPermission = async (method:RequestType = 'request') => {
    const permission = Platform.select({
      ios: PERMISSIONS.IOS.PHOTO_LIBRARY,
      android: PERMISSIONS.ANDROID.READ_EXTERNAL_STORAGE,
    });

    if (permission) {
      let result;
      if (method === 'check') {
        result = await check(permission);
      } else {
        result = await request(permission);
      }
      setHasPhotoLibraryPermission(result === RESULTS.GRANTED);
      return result === RESULTS.GRANTED;
    }
  };

  const checkAndRequestNotificationPermission = async (method:RequestType = 'request') => {
    let result;
    if (method === 'check') {
      result = await checkNotifications();
    } else {
      result = await requestNotifications();
    }
    setHasNotificationPermission(result.status === RESULTS.GRANTED);
    return result.status === RESULTS.GRANTED;
  };

  const checkAndRequestCalendarPermission = async (method:RequestType = 'request') => {
    const permission = Platform.select({
      ios: PERMISSIONS.IOS.CALENDARS,
      android: PERMISSIONS.ANDROID.READ_CALENDAR,
    });

    if (permission) {
      let result;
      if (method === 'check') {
        result = await check(permission);
      } else {
        result = await request(permission);
      }
      setHasCalendarPermission(result === RESULTS.GRANTED);
      return result === RESULTS.GRANTED;
    }
  };

  return {
    hasMicrophonePermission,
    checkAndRequestMicrophonePermission,
    hasCameraPermission,
    checkAndRequestCameraPermission,
    hasLocationPermission,
    checkAndRequestLocationPermission,
    hasPhotoLibraryPermission,
    checkAndRequestPhotoLibraryPermission,
    hasNotificationPermission,
    checkAndRequestNotificationPermission,
    hasCalendarPermission,
    checkAndRequestCalendarPermission,
  };
};

export default usePermissions;
