/*
 * Copyright (C) 2018 The mokeeOS Project
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

package org.mokee.settings.dirac;

import android.media.audiofx.AudioEffect;
import android.util.Log;
import java.util.UUID;

public class DiracSound extends AudioEffect {

    private static final int DIRACSOUND_PARAM_HEADSET_TYPE = 1;
    private static final int DIRACSOUND_PARAM_EQ_LEVEL = 2;
    private static final int DIRACSOUND_PARAM_MUSIC = 4;

    private static final UUID EFFECT_TYPE_DIRACSOUND =
            UUID.fromString("5b8e36a5-144a-4c38-b1d7-0002a5d5c51b");
    private static final String TAG = "DiracSound";
    private static final boolean DEBUG = true;

    public DiracSound(int priority, int audioSession) {
        super(EFFECT_TYPE_NULL, EFFECT_TYPE_DIRACSOUND, priority, audioSession);
    }

    public int getMusic() throws IllegalStateException,
            IllegalArgumentException, UnsupportedOperationException {
        int[] value = new int[1];
        checkStatus(getParameter(DIRACSOUND_PARAM_MUSIC, value));
        if (DEBUG) Log.d(TAG, "getMusic() -> " + value[0]);
        return value[0];
    }

    public void setMusic(int enable) throws IllegalStateException,
            IllegalArgumentException, UnsupportedOperationException {
        if (DEBUG) Log.d(TAG, "setMusic(" + enable + ")");
        checkStatus(setParameter(DIRACSOUND_PARAM_MUSIC, enable));
    }

    public int getHeadsetType() throws IllegalStateException,
            IllegalArgumentException, UnsupportedOperationException {
        int[] value = new int[1];
        checkStatus(getParameter(DIRACSOUND_PARAM_HEADSET_TYPE, value));
        if (DEBUG) Log.d(TAG, "getHeadsetType() -> " + value[0]);
        return value[0];
    }

    public void setHeadsetType(int type) throws IllegalStateException,
            IllegalArgumentException, UnsupportedOperationException {
        if (DEBUG) Log.d(TAG, "setHeadsetType(" + type + ")");
        checkStatus(setParameter(DIRACSOUND_PARAM_HEADSET_TYPE, type));
    }

    public float getLevel(int band) throws IllegalStateException,
            IllegalArgumentException, UnsupportedOperationException {
        int[] param = new int[2];
        byte[] value = new byte[10];
        param[0] = DIRACSOUND_PARAM_EQ_LEVEL;
        param[1] = band;
        checkStatus(getParameter(param, value));
        float level = new Float(new String(value)).floatValue();
        if (DEBUG) Log.d(TAG, "getLevel(" + band + ") -> " + level);
        return level;
    }

    public void setLevel(int band, float level) throws IllegalStateException,
            IllegalArgumentException, UnsupportedOperationException {
        if (DEBUG) Log.d(TAG, "setLevel(" + band + ", " + level + ")");
        checkStatus(setParameter(new int[]{DIRACSOUND_PARAM_EQ_LEVEL, band},
                String.valueOf(level).getBytes()));
    }
}
