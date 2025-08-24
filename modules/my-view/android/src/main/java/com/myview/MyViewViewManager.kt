package com.myview

import android.graphics.Color
import android.util.Log
import android.view.View
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.MyViewManagerInterface
import com.facebook.react.viewmanagers.MyViewManagerDelegate

@ReactModule(name = MyViewViewManager.NAME)
class MyViewViewManager(context: ReactApplicationContext) : ViewGroupManager<MyViewView>(),
  MyViewManagerInterface<MyViewView> {
  private val mDelegate: MyViewManagerDelegate<MyViewView, MyViewViewManager>

  init {
    mDelegate = MyViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<MyViewView>? {
    return mDelegate
  }

  companion object {
    const val NAME = "MyView"
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): MyViewView {
    return MyViewView(context)
  }

  // 添加自定义属性
  @ReactProp(name = "color")
  override fun setColor(view: MyViewView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  // 设置Ref方法
  override fun reload(view: MyViewView?, option: String?) {
    // TODO: Implement reload
    Log.d(NAME, option.toString())
  }

  // 处理子视图的添加
  override fun addView(parent: MyViewView, child: View, index: Int) {
      parent.addView(child, index)
      // 请求重新布局
      parent.requestLayout()
  }
    
  // 处理子视图的移除
  override fun removeViewAt(parent: MyViewView, index: Int) {
      parent.removeViewAt(index)
      // 请求重新布局
      parent.requestLayout()
  }
    
  // 获取子视图数量
  override fun getChildCount(parent: MyViewView): Int {
      return parent.childCount
  }
  
  // 获取指定位置的子视图
  override fun getChildAt(parent: MyViewView, index: Int): View {
      return parent.getChildAt(index)
  }

}
