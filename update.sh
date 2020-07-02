#/bin/bash
USERNAME=vsonline
SDK_VERSION_SHORT=`curl -s https://modulesdkpreview.blob.core.windows.net/sdk/preview/version.txt`
SDK_VERSION_SHORT=${SDK_VERSION_SHORT:0:8}
SDK_SOURCE=https://azuremlsdktestpypi.azureedge.net/Pipeline-Wrapper-SDK-Preview/$SDK_VERSION_SHORT
SDK_VERSION_LONG=0.1.0.$SDK_VERSION_SHORT
AZ_EXTENSION_SOURCE=https://azuremlsdktestpypi.azureedge.net/Pipeline-Wrapper-SDK-Preview/$SDK_VERSION_SHORT/azure_cli_ml-0.1.0.$SDK_VERSION_SHORT-py3-none-any.whl

PATH_SITE_PACKAGES=/home/vsonline/.local/lib/python3.7/site-packages/
PIP_PATH=/usr/local/bin/pip

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

if [[ $SDK_VERSION_SHORT > $CUR_VERSION_AZUREML_DEFAULTS ]]; then
	$PIP_PATH install -U --extra-index-url=$SDK_SOURCE azureml-defaults==$SDK_VERSION_LONG
fi

if [[ $SDK_VERSION_SHORT > $CUR_VERSION_AZUREML_PIPELINE_CORE ]]; then
	$PIP_PATH install -U --extra-index-url=$SDK_SOURCE azureml-pipeline-core==$SDK_VERSION_LONG
fi

if [[ $SDK_VERSION_SHORT > $CUR_VERSION_AZUREML_DEFAULTS ]]; then
	$PIP_PATH install -U --extra-index-url=$SDK_SOURCE azureml-pipeline-wrapper[notebooks]==$SDK_VERSION_LONG
fi

tmp=`cat ${PATH_SITE_PACKAGES}azureml/_base_sdk_common/_version.py`
CUR_VERSION_AZURE_CLI_ML=${tmp:0-10:8}
if [[ $SDK_VERSION_SHORT > $CUR_VERSION_AZURE_CLI_ML ]]; then
	az extension remove -n azure-cli-ml 
	az extension add --source $AZ_EXTENSION_SOURCE --pip-extra-index-urls $SDK_SOURCE --yes --debug
fi
