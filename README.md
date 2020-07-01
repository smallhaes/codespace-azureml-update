# codespace-azureml-update

##### Background

Codespaces can't synchronize with the image used in ```devcontainer.json```. So, we choose an indirect way to update Azure ML Module and this repository is born for this.

In devcontainer.json, the property of ```"postCreateCommand"``` receives a command string or list of command arguments which would run after the codespace is created. 

##### After the codespace is created
1. codespace will clone this repository to ```~/codespace-azureml-update```
2. A command string will be appended to the tail of ```~/.bashrc```. As a result, ```check_for_update.sh``` will be executed every time we start a bash.

##### More details
1. It will search for a newer version of Azure ML Module every day. 
2. You could manually execute ```bash ~/codespace-azureml-update/update.sh``` to update Azure ML Module

