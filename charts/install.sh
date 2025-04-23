# Install External Secrets Operator
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace \
  --set serviceAccount.create=false \
  --set serviceAccount.name=eso-ksa

# Install ELK Stack
helm repo add elastic https://helm.elastic.co
helm repo update

helm install elasticsearch elastic/elasticsearch \
  --namespace elastic-system \
  --create-namespace \
  --set replicas=1 \
  --set minimumMasterNodes=1

helm install kibana elastic/kibana \
  --namespace elastic-system \
  --set service.type=LoadBalancer

helm install logstash elastic/logstash \
  --namespace elastic-system

# Get the LoadBalancer IP for Kibana
kubectl get svc kibana -n elastic-system

# Install Fluentbit to forward logs to Elasticsearch
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

helm install fluent-bit fluent/fluent-bit \
  --namespace logging \
  --create-namespace \
  --set backend.type=es \
  --set backend.es.host=elasticsearch-master.elastic-system.svc.cluster.local \
  --set backend.es.port=9200 \
  --set backend.es.tls_verify=off \
  --set backend.es.logstash_prefix=cache-logs

