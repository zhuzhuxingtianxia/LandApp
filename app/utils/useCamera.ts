import { useCallback, useState } from 'react';
import * as ImagePicker from 'react-native-image-picker';
import usePermissions from './usePermissions';

interface Action {
  type: 'capture' | 'library';
  options: ImagePicker.CameraOptions | ImagePicker.ImageLibraryOptions;
}

interface CameraOptions {
  takeImage: Action;
  selectImage: Action;
}

const includeExtra = true;
export const CameraOptions: CameraOptions = {
  takeImage: {
    type: 'capture',
    options: {
      saveToPhotos: true,
      mediaType: 'photo',
      includeBase64: false,
      includeExtra,
    },
  },
  selectImage: {
    type: 'library',
    options: {
      selectionLimit: 0,
      mediaType: 'photo',
      includeBase64: false,
      includeExtra,
    },
  },
};

const useCamera = () => {
  const { checkAndRequestCameraPermission } = usePermissions();
  const [takeResponse, setTakeResponse] = useState<ImagePicker.ImagePickerResponse | null>(null);

  const onTake = useCallback(async (camera: Action) => {
    const hasPermission = await checkAndRequestCameraPermission();
    if (!hasPermission) {
      console.log('------相机权限未通过------');
      return;
    }

    if (camera.type === 'capture') {
      ImagePicker.launchCamera(camera.options, setTakeResponse);
    } else {
      ImagePicker.launchImageLibrary(camera.options, setTakeResponse);
    }
  }, [checkAndRequestCameraPermission]);

  return {
    takeResponse,
    onTake,
  };
};

export default useCamera;
