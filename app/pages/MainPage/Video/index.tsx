
import React,{ useRef } from 'react';
import { StyleSheet } from 'react-native';
import Video, {VideoRef} from 'react-native-video';


const VideoPlayer = () => {
    const videoRef = useRef<VideoRef>(null);
    const background = require('@assets/source/video_qy.mp4');
   
    const onBuffer = (buffer: any) => {
        
    }

    const onError = (error: any) => {
       console.log(error)
    }

    return (
      <Video 
       // Can be a URL or a local file.
       source={background}
       // Store reference  
       ref={videoRef}
       // Callback when remote video is buffering                                      
       onBuffer={onBuffer}
       // Callback when video cannot be loaded              
       onError={onError}               
       style={styles.backgroundVideo}
      />
    )
   }
   
   // Later on in your styles..
   const styles = StyleSheet.create({
     backgroundVideo: {
       position: 'absolute',
       top: 0,
       left: 0,
       bottom: 0,
       right: 0,
     },
   });

   export default VideoPlayer;