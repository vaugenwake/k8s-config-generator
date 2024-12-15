#!/usr/bin/env bash

TEMPLATE="config.yaml.tmp"

CURRENT_CONTEXT=$(kubectl config current-context)

NAMESPACES_LIST=$(kubectl get ns --no-headers -o custom-columns=":metadata.name")

NAMESPACE=$(echo $NAMESPACES_LIST | tr ' ' '\n' | gum filter --header "Select a namespace")

SERVICE_ACCOUNTS=$(kubectl get serviceaccount -n $NAMESPACE --no-headers -o custom-columns=":metadata.name")

SERVICE_ACCOUNT_NAME=$(echo $SERVICE_ACCOUNTS | tr ' ' '\n' | gum filter --header "Select a service account")

SECRETS_LIST=$(kubectl get secret -n $NAMESPACE --no-headers -o custom-columns=":metadata.name")
SECRET_NAME=$(echo $SECRETS_LIST | tr ' ' '\n' | gum filter --header "Service account token secret")

CURRENT_CLUSTER_URL=$(kubectl config view --minify --context=$CURRENT_CONTEXT -o jsonpath='{.clusters[*].cluster.server}')

NEW_CONTEXT=$(gum input --placeholder "New context name (default: default)")
CLUSTER_URL=$(gum input --placeholder "Cluster URL" --value "$CURRENT_CLUSTER_URL")
KUBECONFIG_FILE=$(gum input --placeholder "New config name (format: *.yaml)")

echo "Service Account: $SERVICE_ACCOUNT_NAME"
echo "Secret Name: $SECRET_NAME"
echo "Namespace: $NAMESPACE"
echo "New Context: $NEW_CONTEXT"
echo "Config file: $KUBECONFIG_FILE"
echo "Cluster URL: $CLUSTER_URL"

SECRET_TOKEN=$(kubectl get secret/$SECRET_NAME -n $NAMESPACE -o jsonpath='{.data.token}' | base64 -d)

CLUSTER_CA=$(kubectl get secret/$SECRET_NAME -n $NAMESPACE -o jsonpath='{.data.ca\.crt}')

cp ${TEMPLATE} ${KUBECONFIG_FILE}

sed -i '' -e "s#NAMESPACE_NAME#$NAMESPACE#g" $KUBECONFIG_FILE
sed -i '' -e "s#CLUSTER_NAME#$NEW_CONTEXT#g" $KUBECONFIG_FILE
sed -i '' -e "s#CONTEXT_NAME#$NEW_CONTEXT#g" $KUBECONFIG_FILE
sed -i '' -e "s#SERVICE_ACCOUNT_NAME#$SERVICE_ACCOUNT_NAME#g" $KUBECONFIG_FILE
sed -i '' -e "s#SERVICE_TOKEN#$SECRET_TOKEN#g" $KUBECONFIG_FILE
sed -i '' -e "s#CLUSTER_URL#$CLUSTER_URL#g" $KUBECONFIG_FILE
sed -i '' -e "s#CLUSTER_CA#$CLUSTER_CA#g" $KUBECONFIG_FILE