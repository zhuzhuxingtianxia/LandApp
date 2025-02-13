package qiuxiang.amap3d.map_view;


import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import org.json.JSONArray;
import org.json.JSONObject;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import qiuxiang.amap3d.R;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class LocationService extends Service {
    private AMapLocationClient locationClient;
    private AMapLocationClientOption locationOption;
    private MediaPlayer mediaPlayer;

    private static final String TAG = "LocationService";


    private long sid;

    private long tid;

    private long trid;

    @Override
    public void onCreate() {
        super.onCreate();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification notification = createForegroundNotification();
            notification.flags = Notification.FLAG_NO_CLEAR;
            startForeground(1, notification);
        }
        // 初始化定位
        try {
            locationClient = new AMapLocationClient(getApplicationContext());
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        locationOption = new AMapLocationClientOption();
        locationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy); // 高精度定位
        locationOption.setInterval(5000); // 定位间隔5秒
        locationClient.setLocationOption(locationOption);
        locationClient.setLocationListener(new AMapLocationListener() {
            @Override
            public void onLocationChanged(AMapLocation amapLocation) {
                if (amapLocation != null && amapLocation.getErrorCode() == 0) {
                    // 获取定位信息，上传到服务器
                    double latitude = amapLocation.getLatitude();
                    double longitude = amapLocation.getLongitude();
                    uploadLocationToServer(latitude, longitude);
                }
            }
        });

        // 初始化MediaPlayer播放无声音乐
        initMediaPlayer();
    }


    /**
     * 创建通知
     */
    private Notification createForegroundNotification() {
        String channelId = "NotificationLocationService";
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String channelName = "上传车辆定位";

            NotificationChannel channel = new NotificationChannel(channelId,
                    channelName, NotificationManager.IMPORTANCE_HIGH);
            channel.setLightColor(Color.BLUE);
            channel.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
            NotificationManager service = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            service.createNotificationChannel(channel);
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, channelId);
        builder.setContentTitle("车辆定位上传");
        builder.setContentText("为保持车辆定位上传,请勿关闭此服务");
        builder.setWhen(System.currentTimeMillis());
        builder.setSmallIcon(R.drawable.ic_launcher);
        builder.setWhen(System.currentTimeMillis());
        return builder.build();

    }

    private void initMediaPlayer() {
        mediaPlayer = new MediaPlayer();
        try {
            // 使用一个无声音频文件，可以将raw/silent.mp3放置在res/raw目录下
            AssetFileDescriptor afd = getResources().openRawResourceFd(R.raw.coun_down);
            mediaPlayer.setDataSource(afd.getFileDescriptor(), afd.getStartOffset(), afd.getLength());
            afd.close();
            mediaPlayer.setVolume(0.0f,0.0f);
            mediaPlayer.setLooping(true); // 设置为循环播放
            mediaPlayer.prepare();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static class CustomHeaderInterceptor implements okhttp3.Interceptor {
        @Override
        public Response intercept(Chain chain) throws IOException {
            Request originalRequest = chain.request();
            Request modifiedRequest = originalRequest.newBuilder()
                    .header("crqTime", String.valueOf(System.currentTimeMillis()))
                    .build();
            return chain.proceed(modifiedRequest);
        }
    }

    private void uploadLocationToServer(double latitude, double longitude) {
        // 在这里实现上传逻辑，例如通过HTTP请求将位置信息上传到服务器
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    OkHttpClient client = new OkHttpClient.Builder()
                            .addInterceptor(new CustomHeaderInterceptor())
                            .connectTimeout(23, TimeUnit.DAYS) //连接超时
                            .build();
                    String key = "5b7b19575eb530b5d7ca2f9f3b3f0788";
                    String baseUrl = "https://tsapi.amap.com/v1/track/point/upload";
                    String formattedLongitude = String.format("%.6f", longitude);
                    String formattedLatitude = String.format("%.6f", latitude);

                    JSONArray jsonArray = new JSONArray();
                    JSONObject point = new JSONObject();
                    point.put("location", formattedLongitude + "," + formattedLatitude);
                    point.put("locatetime", new Date().getTime());
                    jsonArray.put(point);

                    String urlWithParams = baseUrl + "?key=" + key
                            + "&sid=" + String.valueOf(sid)
                            + "&tid=" + String.valueOf(tid)
                            + "&trid=" + String.valueOf(trid)
                            + "&points=" + jsonArray;
                    RequestBody body = RequestBody.create("", MediaType.parse("application/x-www-form-urlencoded; charset=utf-8"));
                    Request request = new Request.Builder()
                            .url(urlWithParams)
                            .post(body)
                            .build();

                    client.newCall(request).enqueue(new Callback() {
                        @Override
                        public void onFailure(Call call, IOException e) {
                            e.printStackTrace();
                        }

                        @Override
                        public void onResponse(Call call, Response response) throws IOException {
                            if (response.isSuccessful()) {
                                String responseBody = response.body().string();
                                System.out.println("Response: " + responseBody);
                                response.body().close();
                            } else {
                                System.err.println("Request failed: " + response.message());
                            }
                        }
                    });

                } catch (Exception e) {
                    Log.e(TAG, "请求错误: ", e);
                }
            }
        }).start();

    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        sid = Long.parseLong(intent.getStringExtra("sid"));
        tid = Long.parseLong(intent.getStringExtra("tid"));
        trid = Long.parseLong(intent.getStringExtra("trid"));

        locationClient.startLocation();  // 开始定位
        mediaPlayer.start();  // 播放无声音乐
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        locationClient.stopLocation(); // 停止定位
        mediaPlayer.stop();  // 停止音乐
        mediaPlayer.release();  // 释放资源
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
