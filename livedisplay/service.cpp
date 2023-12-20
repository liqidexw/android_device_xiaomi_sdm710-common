/*
 * Copyright (C) 2019-2021 The mokeeOS Project
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

#define LOG_TAG "mokee.livedisplay@2.1-service.xiaomi_sdm710"

#include <android-base/logging.h>
#include <binder/ProcessState.h>
#include <hidl/HidlTransportSupport.h>

#include "AntiFlicker.h"
#include "SunlightEnhancement.h"
#include "livedisplay/sdm/SDMController.h"

using android::OK;
using android::sp;
using android::status_t;
using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;

using ::vendor::mokee::livedisplay::V2_0::sdm::SDMController;
using ::vendor::mokee::livedisplay::V2_1::IAntiFlicker;
using ::vendor::mokee::livedisplay::V2_1::ISunlightEnhancement;
using ::vendor::mokee::livedisplay::V2_1::implementation::AntiFlicker;
using ::vendor::mokee::livedisplay::V2_1::implementation::SunlightEnhancement;

int main() {
    sp<AntiFlicker> antiFlicker = new AntiFlicker();
    sp<SunlightEnhancement> sunlightEnhancement = new SunlightEnhancement();
    std::shared_ptr<SDMController> controller = std::make_shared<SDMController>();
    status_t status = OK;

    LOG(INFO) << "LiveDisplay HAL custom service is starting.";

    if (!antiFlicker->isSupported()) {
        LOG(ERROR) << "AntiFlicker Iface is not supported, gracefully bailing out.";
        return 1;
    }

    if (!sunlightEnhancement->isSupported()) {
        LOG(ERROR) << "SunlightEnhancement Iface is not supported, gracefully bailing out.";
        return 1;
    }

    configureRpcThreadpool(1, true /*callerWillJoin*/);

    status = antiFlicker->registerAsService();
    if (status != OK) {
        LOG(ERROR) << "Could not register service for LiveDisplay HAL AntiFlicker Iface ("
                   << status << ")";
        goto shutdown;
    }

    status = sunlightEnhancement->registerAsService();
    if (status != OK) {
        LOG(ERROR) << "Could not register service for LiveDisplay HAL SunlightEnhancement Iface ("
                   << status << ")";
        goto shutdown;
    }

    LOG(INFO) << "LiveDisplay HAL custom service is ready.";
    joinRpcThreadpool();
    // Should not pass this line

shutdown:
    // In normal operation, we don't expect the thread pool to shutdown
    LOG(ERROR) << "LiveDisplay HAL custom service is shutting down.";
    return 1;
}
