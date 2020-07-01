#!/bin/bash

# record the last update epoch
SDK_UPDATE_LOCK_DIR=~/.sdk_update_lock_dir
if [[ ! -d ${SDK_UPDATE_LOCK_DIR} ]]; then
        mkdir ${SDK_UPDATE_LOCK_DIR}
fi

# get the current epoch
function _current_epoch() {
        cur=`date '+%s'`
        echo $(( $cur  / 60 / 60 / 24 ))
}

# get the epoch of last update 
function _last_epoch() {
        if [[ ! -f ${SDK_UPDATE_LOCK_DIR}/sdk_update_lock ]]; then
                touch ${SDK_UPDATE_LOCK_DIR}/sdk_update_lock
        fi
        LAST_EPOCH=`stat -c %Y ${SDK_UPDATE_LOCK_DIR}/sdk_update_lock`
        echo $(( $LAST_EPOCH / 60 / 60 / 24 ))
}

# check for update every day
epoch_interval_min=-2

# interval from last updating
epoch_interval=$(($(_current_epoch) - $(_last_epoch)))

if [[ $epoch_interval -gt $epoch_interval_min ]]; then
        # version of sdk in codespace
        CUR_VERSION=`pip show azureml-pipeline-wrapper | grep Version | cut -d "." -f 4`
        # newest version of sdk
        NEW_VERSION=`curl -s https://versionofsdk.blob.core.windows.net/versionofsdk/version.txt`
        # need to update
        if [[ $NEW_VERSION > $CUR_VERSION ]]; then
                echo -e "Current version of Azure Module SDK is ${CUR_VERSION}. A new version of ${NEW_VERSION} has been released. Would you like to update right now? [Y/n]: \c"
                read line
                if [[ "$line" == Y* ]] || [[ "$line" == y* ]] || [ -z "$line" ]; then
                        pwd
                        . ~/codespace-azureml-update/update.sh
                        touch ${SDK_UPDATE_LOCK_DIR}/sdk_update_lock
                else
                        echo "You could run 'bash ~/codespace-azureml-update/update.sh' to update later."
                fi
        fi
fi



