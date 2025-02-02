/*
 * Copyright (C) 2020 The mokeeOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.mokee.settings.thermal;

import android.app.ActivityManager;
import android.app.ActivityManager.StackInfo;
import android.app.IActivityManager;
import android.app.TaskStackListener;
import android.app.ActivityTaskManager;
import android.app.Service;
import android.content.ComponentName;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

public class ThermalService extends Service {

    private static final String TAG = "ThermalService";
    private static final boolean DEBUG = false;

    private String mPreviousApp;
    private ThermalUtils mThermalUtils;
    private IActivityManager mIActivityManager;

    private BroadcastReceiver mIntentReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            mPreviousApp = "";
            mThermalUtils.setDefaultThermalProfile();
        }
    };

    @Override
    public void onCreate() {
        if (DEBUG) Log.d(TAG, "Creating service");
        try {
            ActivityTaskManager.getService().registerTaskStackListener(mTaskListener);
        } catch (RemoteException e) {
            // Do nothing
        }
        mThermalUtils = new ThermalUtils(this);
        mIActivityManager = ActivityManager.getService();
        registerReceiver();
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (DEBUG) Log.d(TAG, "Starting service");
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void registerReceiver() {
        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_SCREEN_OFF);
        this.registerReceiver(mIntentReceiver, filter);
    }

    private final TaskStackListener mTaskListener = new TaskStackListener() {
        @Override
        public void onTaskStackChanged() {
            try {
                final StackInfo focusedStack = mIActivityManager.getFocusedStackInfo();
                if (focusedStack != null && focusedStack.topActivity != null) {
                    ComponentName taskComponentName = focusedStack.topActivity;
                    String foregroundApp = taskComponentName.getPackageName();
                    if (!foregroundApp.equals(mPreviousApp)) {
                        mThermalUtils.setThermalProfile(foregroundApp);
                        mPreviousApp = foregroundApp;
                    }
                }
            } catch (RemoteException ignored) {
            }
        }
    };
}
