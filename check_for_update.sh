#!/bin/bash

#.sdk_update_lock_dir目录下的sdk_update_lock用于记录上一次检查更新的时间
SDK_UPDATE_LOCK_DIR=~/.sdk_update_lock_dir
if [[ ! -d ${SDK_UPDATE_LOCK_DIR} ]]; then
        mkdir ${SDK_UPDATE_LOCK_DIR}
fi

#获取当前的时间戳
function _current_epoch() {
        cur=`date '+%s'`
        echo $(( $cur  / 60 / 60 / 24 ))
}

function _last_epoch() {
        if [[ ! -f ${SDK_UPDATE_LOCK_DIR}/sdk_update_lock ]]; then
                touch ${SDK_UPDATE_LOCK_DIR}/sdk_update_lock
        fi
        LAST_EPOCH=`stat -c %Y ${SDK_UPDATE_LOCK_DIR}/sdk_update_lock`
        echo $(( $LAST_EPOCH / 60 / 60 / 24 ))
}

#检查更新的时间间隔是1天
epoch_interval_min=-2

#计算当前时间距离上次检查更新的时间
epoch_interval=$(($(_current_epoch) - $(_last_epoch)))

if [[ $epoch_interval -le $epoch_interval_min ]]; then
       exit
fi

# 获取当前的sdk版本
CUR_VERSION=`pip show azureml-pipeline-wrapper | grep Version | cut -d "." -f 4`
# 获取最新的sdk版本
NEW_VERSION=`curl -s https://versionofsdk.blob.core.windows.net/versionofsdk/version.txt`
# 如果版本没有变化则不用更新
if [[ $NEW_VERSION == $CUR_VERSION ]]; then
       exit
fi

if [[ $NEW_VERSION > $CUR_VERSION ]]; then
        echo -e "Found new releases of Azure Module SDK which take about 15 minutes to update. Would you like to  update them right now? [Y/n]: \c"
        read line
        if [[ "$line" == Y* ]] || [[ "$line" == y* ]] || [ -z "$line" ]; then
                pwd
                . ~/codespace-azureml-update/update.sh
                touch ${SDK_UPDATE_LOCK_DIR}/sdk_update_lock
        else
                echo "You could run 'bash ~/codespace-azureml-update/update.sh' to update SDKs yourself."
        fi
fi