# Infrastructure

## AWS Zones
2 regions: us-east-2 and us-west-1

## Servers and Clusters

### Table 1.1 Summary
| Asset                                                    | Purpose                                                                  | Size                                                                   | Qty                                                             | DR                                                                                                           |
|----------------------------------------------------------|--------------------------------------------------------------------------|------------------------------------------------------------------------|-----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| EC2 instances (us-east-2)                                | To run web application                                                   | t3.micro                                                               | 3                                                               | Created in multi AZs                                                                                         |
| EC2 instances (us-west-1)                                | To run web application                                                   | t3.micro                                                               | 3                                                               | Deployed to DR                                                                                               |
| SSH keys                                                 | SSH to instances                                                         |                                                                        | 1 in us-east-2 and 1 in us-west-1                               |                                                                                                              |
| GitHub repo                                              | Store TF code                                                            |                                                                        |                                                                 |                                                                                                              |
| Kubernetes cluster (us-east-2) with node group instances | Monitoring platform (Grafana and Prometheus) to monitor web application  | instance size t3.medium                                                | 1 eks_node_group has 2 instances                                | Instances created in multi AZs                                                                               |
| Kubernetes cluster (us-west-1) with node group instances | Monitoring platform (Grafana and Prometheus) to monitor web application  | instance size t3.medium                                                | 1 eks_node_group has 2 instances                                | Instances deployed to DR                                                                                     |
| VPC (us-east-2 and us-west-1)                            | Virtual network that can set up public/private subnets in multi AZs      |                                                                        | 1 in us-east-2 and 1 in us-west-1                               |                                                                                                              |
| Application load balancer (us-east-2)                    | To route traffic to healthy EC2 instances                                |                                                                        | 1                                                               | Created                                                                                                      |
| Application load balancer (us-west-1)                    | To route traffic to healthy EC2 instances                                |                                                                        | 1                                                               | Deployed to DR                                                                                               |
| Aurora MySQL clusters/instances (us-east-2)              | To store data from web application                                       | db.t2.small                                                            | 1 cluster and 2 db instances (in different AZs)                 | Created in multi AZs                                                                                         |
| Aurora MySQL clusters/instances (us-west-1)              | To store data from web application                                       | db.t2.small                                                            | 1 cluster and 2 db instances (in different AZs)                 | Replicated in another region to DR                                                                           |

### Descriptions
Each region has:
- 3 EC2 instances in different AZs to run web application. In case 1 instance is offline, the ALB will route web requests to the other healthy instances
- 1 Kubernetes cluster with 1 node group that has 2 EC2 instances for monitoring platform (Grafana and Prometheus) to monitor metrics in web application
- 1 VPC with public/private subnets in multi AZs
- ALB to route traffic to healthy EC2 instances running web application. In case ALB in 1 region is down, point DNS to ALB in the other region.
- 1 Aurora MySQL cluster with 2 database instances in different AZs. 
  - Primary cluster is in us-east-2. 
  - Secondary cluster (which is a replica of the primary cluster) is in us-west-1.
  - Backup retention is 5 days
  - Within a region, if writer instance is offline, failover to reader instance.
  - If main region (us-east-2) is down, failover to replica cluster in secondary region (us-west-1) and the secondary cluster becomes primary cluster.

## DR Plan
### Pre-Steps:
- Application: in the other region (us-west-2), deploy the identical ALB and EC2 instances with web application running. 
- Database cluster: in the other region (us-west-2), deploy the same aurora mysql cluster (and instances) which is a replica of the primary cluster which is in us-east-2

## Steps:
- Application: in case us-east-2 is down, we will need to point DNS to ALB in us-west-1
- Database cluster: in case us-east-2 is down, the failover happens automatically, secondary cluster in us-west-1 becomes the primary cluster, we will need to point web application to the cluster endpoint of us-west-1 
