#!/usr/bin/env sh

# merge-kubeconfigs.sh [path to k3s kubeconfig] [k3s master node ip] [merge kubeconfigs?] [new cluster name for k3s cluster when merged]

# Set server address. K3s always uses 'default' for cluster name
kubectl --kubeconfig ${1} config set clusters.default.server https://${2}:6443

if [ "true" == "${3}" ]; then
    # rename everything in the downloaded file. K3s always uses 'default'
    replacePattern=": ${4}"
    sed -i "s/: default/$replacePattern/g" ${1}

    # if current config exists, backu and merge, otherwise copy
    timeStamp="$(date +%Y-%m-%d.%H-%M-%S)"
    currentConfig=${KUBECONFIG:-${HOME}/.kube/config}
    if [ -e "${currentConfig}" ]; then
        # backup
        cp "${currentConfig}" "${currentConfig}.${timeStamp}"
        # merge backup and new into current
        KUBECONFIG=${currentConfig}.${timeStamp}:${1} kubectl config view --flatten > "${currentConfig}"
    else
        cp ${1} ${currentConfig}
    fi

    # set context
    kubectl --kubeconfig "${currentConfig}" config use-context "${4}"
fi