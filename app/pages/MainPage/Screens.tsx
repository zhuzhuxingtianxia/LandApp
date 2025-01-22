/**
 * @description: Login page screens
*/

import { bar_config_base, bar_config_hide } from '@/utils/navigationBarConfig';
import HomePage from './HomePage';
import H5 from './H5';
import Guide from './Guide';
import Ad from './Ad';

import { Main } from '@pages/Launch/RouteConst';
import Blur from './Blur';
import Gradient from './Gradient';
import Video from './Video';
import Masked_View from './Masked_View';
import ImagePickerPage from './ImagePickerPage';
import CarouselPage from './CarouselPage';
import QRCodePage from './QRCodePage';
import LottiePage from './LottiePage';
import FailingComponent from '@/components/FailingComponent';

const MianScreens = [
    {
      name: Main.HomePage,
      component: HomePage,
      options: {
        ...bar_config_hide,
        title: '首页',
      },
    },
    {
      name: Main.Guide,
      component: Guide,
      options: {
        ...bar_config_hide,
        title: '引导页',
      },
    },
    {
      name: Main.Ad,
      component: Ad,
      options: {
        ...bar_config_hide,
        title: '广告页',
      },
    },
    {
      name: Main.H5,
      component: H5,
      options: {
        title: 'H5',
      },
    },
    {
      name: Main.Blur,
      component: Blur,
      options: {
        // presentation: 'transparentModal', // 半透明
        // presentation: 'fullScreenModal', 
        title: '模糊',
      },
    },
    {
      name: Main.Gradient,
      component: Gradient,
    },
    {
      name: Main.Video,
      component: Video,
    },
    {
      name: Main.Masked_View,
      component: Masked_View,
    },
    {
      name: Main.ImagePickerPage,
      component: ImagePickerPage,
    },
    {
      name: Main.CarouselPage,
      component: CarouselPage,
    },
    {
      name: Main.QRCodePage,
      component: QRCodePage,
    },
    {
      name: Main.LottiePage,
      component: LottiePage,
    },
    {
      name: Main.FailingComponent,
      component: FailingComponent,
    },
];

export default MianScreens;
