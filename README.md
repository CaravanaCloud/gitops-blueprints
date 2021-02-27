# eks-blueprint

A sample "working" Kubernetes cluster on EKS, with cloudformation, terraform and all that jazz.

# HOWTO

1. Deploy the storage tier (s3, efs, ...) once per account

```
./storage/redeploy.sh
```

2. Deploy the cluster, or as many as you'd like

```
./main/redeploy.sh
```

3. May the force be with you...
