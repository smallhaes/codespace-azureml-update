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
epoch_interval_min=1

# interval from last updating
epoch_interval=$(($(_current_epoch) - $(_last_epoch)))

if [[ $epoch_interval -gt $epoch_interval_min ]]; then
        # version of sdk in codespace
        PATH_SITE_PACKAGES=/home/vsonline/.local/lib/python3.7/site-packages/
        tmp=`ls -d ${PATH_SITE_PACKAGES}azureml_defaults*`
        CUR_VERSION_AZUREML_DEFAULTS=${tmp:0-18:8}
        tmp=`ls -d ${PATH_SITE_PACKAGES}azureml_pipeline_core*`
        CUR_VERSION_AZUREML_PIPELINE_CORE=${tmp:0-18:8}
        tmp=`ls -d ${PATH_SITE_PACKAGES}azureml_pipeline_wrapper*`
        CUR_VERSION_AZUREML_PIPELINE_WRAPPER=${tmp:0-18:8}
        MIN=$CUR_VERSION_AZUREML_DEFAULTS
        if [[ $MIN > $CUR_VERSION_AZUREML_PIPELINE_CORE ]]; then
            MIN=$CUR_VERSION_AZUREML_PIPELINE_CORE
        fi
        if [[ $MIN > $CUR_VERSION_AZUREML_PIPELINE_WRAPPER ]]; then
            MIN=$CUR_VERSION_AZUREML_PIPELINE_WRAPPER
        fi
        # newest version of sdk
        NEW_VERSION=`curl -s https://modulesdkpreview.blob.core.windows.net/sdk/preview/version.txt`
        NEW_VERSION=${NEW_VERSION:0:8}
        # need to update
        if [[ ${#NEW_VERSION} == 8 ]] && ( [[ $NEW_VERSION > $CUR_VERSION_AZUREML_DEFAULTS ]] || [[ $NEW_VERSION > $CUR_VERSION_AZUREML_PIPELINE_CORE ]] || [[ $NEW_VERSION > $CUR_VERSION_AZUREML_PIPELINE_WRAPPER ]] ); then
                echo -e "Current version of Azure ML Module is ${MIN}. A new version of ${NEW_VERSION} has been released. Would you like to update right now? [Y/n]: \c"
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



