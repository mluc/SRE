#!/bin/bash

kubectl apply -f apps/blue-green/green.yml
until [ $(kubectl get pod | grep -c 'green-') -eq 3 ]
do
  echo "waiting for green deployment"
  sleep 5
done

cd infra
terraform init
terraform apply -target=kubernetes_service.green -auto-approve

GREEN_IP=$(kubectl get svc | grep green-svc | awk '{ print $4 }')
# wait until the service to be reachable
until [ $(curl -s $GREEN_IP | grep -c 'GREEN') -gt 0 ]
do
  echo "waiting for the service to be reachable"
  sleep 5
done

terraform apply -target=aws_route53_record.green -auto-approve

# sleep 5 minutes to connect to ec2 instance and run `curl blue-green.udacityproject` command
# both green & blue services are reachable
echo "Sleeping for 5 minutes to connect to ec2 instance"
sleep 300

# failover event to the green
terraform destroy -target=aws_route53_record.blue -auto-approve

# sleep 5 minutes to connect to ec2 instance and run `curl blue-green.udacityproject` command
# only returns the green environment
echo "Sleeping for 5 minutes to connect to ec2 instance"
sleep 300

# clean up blue
terraform destroy -target=kubernetes_service.blue -auto-approve
cd ..
kubectl delete -f apps/blue-green/blue.yml