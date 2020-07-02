#/bin/bash
USERNAME=vsonline
SDK_VERSION_SHORT=`curl -s https://modulesdkpreview.blob.core.windows.net/sdk/preview/version.txt`
SDK_VERSION_SHORT=${SDK_VERSION_SHORT:0:8}
SDK_SOURCE=https://azuremlsdktestpypi.azureedge.net/Pipeline-Wrapper-SDK-Preview/$SDK_VERSION_SHORT
SDK_VERSION_LONG=0.1.0.$SDK_VERSION_SHORT
AZ_EXTENSION_SOURCE=https://azuremlsdktestpypi.azureedge.net/Pipeline-Wrapper-SDK-Preview/$SDK_VERSION_SHORT/azure_cli_ml-0.1.0.$SDK_VERSION_SHORT-py3-none-any.whl

PATH_SITE_PACKAGES=/home/vsonline/.local/lib/python3.7/site-packages/
PIP_PATH=/usr/local/bin/pip

$PIP_PATH install -U --extra-index-url=$SDK_SOURCE azureml-defaults==$SDK_VERSION_LONG azureml-pipeline-core==$SDK_VERSION_LONG azureml-pipeline-wrapper[notebooks]==$SDK_VERSION_LONG

tmp=`cat ${PATH_SITE_PACKAGES}azureml/_base_sdk_common/_version.py`
CUR_VERSION_AZURE_CLI_ML=${tmp:0-10:8}
if [[ $SDK_VERSION_SHORT > $CUR_VERSION_AZURE_CLI_ML ]]; then
	az extension remove -n azure-cli-ml 
	az extension add --source $AZ_EXTENSION_SOURCE --pip-extra-index-urls $SDK_SOURCE --yes --debug
fi
