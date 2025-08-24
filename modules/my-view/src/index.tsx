import React from 'react';
import type { NativeProps } from './fabric';
import { Commands, MyView as IMyView } from './fabric';

export interface MyViewRef {
  reload: (flag?: string) => void;
}

const MyView = React.forwardRef((props: NativeProps, ref: React.Ref<MyViewRef>) => {

  const myRef = React.useRef(null);

  React.useImperativeHandle(ref, ()=>({
    reload: (flag?: string) => {
      if(myRef.current) {
        Commands.reload?.(myRef.current, flag);
      }else {
        console.log('Ref.current is null');
      }
    },
  }));

  return (
    <IMyView {...props} ref={myRef}/>
  );
});

export default MyView;
export { MyView };
