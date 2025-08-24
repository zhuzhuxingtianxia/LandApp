package com.myview

import android.content.Context
import android.util.AttributeSet
import android.widget.FrameLayout
import com.facebook.react.views.view.ReactViewGroup
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.events.Event

class MyViewView(context: Context) : ReactViewGroup(context) {
  init {
    configureComponent()
  }

  private fun configureComponent() {
    this.layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
  }
  // 当 View 被附加到窗口时调用
  override fun onAttachedToWindow() {
      super.onAttachedToWindow()
      onWillShow()
  }

  // 当视图可见性发生变化时调用
  override fun onVisibilityChanged(changedView: android.view.View, visibility: Int) {
      super.onVisibilityChanged(changedView, visibility)
  }

  fun onWillShow() {
    val reactContext = context as ReactContext
    val surfaceId = UIManagerHelper.getSurfaceId(reactContext)
    val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(reactContext, id)

    val payload =
        Arguments.createMap().apply {
          putString("flag", "传递的数据android")
        }
    val event = OnWillShowEvent(surfaceId, id, payload)

    eventDispatcher?.dispatchEvent(event)
  }

  inner class OnWillShowEvent(
      surfaceId: Int,
      viewId: Int,
      private val payload: WritableMap
  ) : Event<OnWillShowEvent>(surfaceId, viewId) {
    override fun getEventName() = "onWillShow"

    override fun getEventData() = payload
  }

}
