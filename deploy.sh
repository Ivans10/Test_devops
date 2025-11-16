-----------------------------------------------
PARTE 3: DEPLOYMENT &amp; TROUBLESHOOTING 
3.1 Crea uno script di deployment


## Output command: 
cat deploy.sh 
-----------------------------------------------
#!/bin/bash
cd /TEST_DEVOPS/TEST_HELM/charts 

## 1. Valida i charts Helm
	helm lint backend 
	helm lint frontend 
	helm lint postgres 
	helm lint redis 

## 2. Sostituisci le variabili di environment
	helm install --set replicas=3 backend-dev backend 
	helm install --set replicas=3 frontend-dev frontend 
	helm install --set replicas=3 postgres-dev postgres 
	helm install --set replicas=3 redis-dev redis 

	helm install -f values-staging.yaml --set replicas=3 backend-staging backend 
	helm install -f values-staging.yaml --set replicas=3 frontend-staging frontend 
	helm install -f values-staging.yaml --set replicas=3 postgres-staging postgres 
	helm install -f values-staging.yaml --set replicas=3 redis-staging redis 

	helm install -f values-prod.yaml --set replicas=3 backend-staging backend 
	helm install -f values-prod.yaml --set replicas=3 frontend-staging frontend 
	helm install -f values-prod.yaml --set replicas=3 postgres-staging postgres 
	helm install -f values-prod.yaml --set replicas=3 redis-staging redis

## 3. Deploy nello specifico namespace con Helm
	helm install backend-dev backend --namespace dev --create=namespace 
	helm install frontend-dev frontend --namespace dev --create=namespace 
	helm install postgres-dev postgres --namespace dev --create=namespace 
	helm install redis-dev redis --namespace dev --create=namespace 

	helm install -f values-staging.yaml backend-staging backend --namespace staging --create=namespace
	helm install -f values-staging.yaml frontend-staging frontend --namespace staging --create=namespace
	helm install -f values-staging.yaml postgres-staging postgres --namespace staging --create=namespace
	helm install -f values-staging.yaml redis-staging redis --namespace staging --create=namespace

	helm install -f values-prod.yaml backend-prod backend --namespace prod --create=namespace
	helm install -f values-prod.yaml frontend-prod frontend --namespace prod --create=namespace
	helm install -f values-prod.yaml postgres-prod postgres --namespace prod --create=namespace
	helm install -f values-prod.yaml redis-prod redis --namespace prod --create=namespace

## 4. Attendi che i rollout siano completi 
	helm upgrade --install backend-dev --wait --namespace dev
	helm upgrade --install backend-staging --wait --namespace staging
	helm upgrade --install backend-prod --wait --namespace prod

	helm upgrade --install frontend-dev --wait --namespace dev
	helm upgrade --install frontend-staging --wait --namespace staging
	helm upgrade --install frontend-prod --wait --namespace prod

	helm upgrade --install postgres-dev --wait --namespace dev
	helm upgrade --install postgres-staging --wait --namespace staging
	helm upgrade --install postgres-prod --wait --namespace prod

	helm upgrade --install redis-dev --wait --namespace dev
	helm upgrade --install redis-staging --wait --namespace staging
	helm upgrade --install redis-prod --wait --namespace prod

## 5. Esegui smoke tests di base
##Smoke tests minimali:
##	● Verifica che tutti i pods siano running
##	● Verifica che gli Ingress abbiano IP/DNS assegnato
##	● Test curl endpoint /health dell'API
##	● Verifica connessione MySQL da pod (psql -c "SELECT 1")
##	● Verifica connessione Redis (redis-cli PING)
	kubectl get pod -n dev[staging, prod]
	kubectl describe ingress -n dev[staging, prod]
	kubectl get ep -n dev[staging, prod]
		curl http://endpoint:port/health
	kubectl exec -n dev[staging, prod] deployment/postgres-dev [staging, prod] --container postgres-dev [staging, prod] -it -- psql -c "SELECT 1"
	kubectl exec -n dev[staging, prod] deployment/redis-dev [staging, prod] --container postgres-dev [staging, prod] -it -- redis-cli PING

## 6. Output status del deployment
	kubectl rollout status -n dev[staging, prod] deployment/backend-dev [staging, prod] 
	kubectl rollout status -n dev[staging, prod] deployment/frontend-dev [staging, prod] 
	kubectl rollout status -n dev[staging, prod] deployment/postgres-dev [staging, prod] 
	kubectl rollout status -n dev[staging, prod] deployment/redis-dev [staging, prod] 

