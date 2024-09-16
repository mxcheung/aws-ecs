#!/bin/bash
   
ECS_CREATE_CLUSTER_OUTPUT=$(aws ecs create-cluster --cluster-name Wordpress-Cluster)
    
