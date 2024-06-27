#!/bin/bash
#
# Example useage
#
# default example:
# setup_project_repo.sh
#
# instavote apps:
# setup_project_repo.sh redis
# setup_project_repo.sh results
# setup_project_repo.sh vote
# setup_project_repo.sh worker
#

# overlays
MY_OVERLAYS=("production" "staging" "testing")

# kustomize repo - arg 1, or example
KUSTOMIZE_BASE="kustomize/${1:-example-project}"

mkdir -p flux kustomize helm

# main readme is maintained as append, but only run 1x
if [ ! -f "flux/base/README.md" ]; then
cat >>  README.md <<EOF
## Deployment Repo

This repository contains code to deploy to kubernetes. 

Type of code and their respective paths are, 

  * flux/*  :  Deployment/Sync Manifests for FluxCD.   
  * kustomize/*  : Either plain YAMLs or additinally environment specific kustomize overlays. 
  * helm/* : Helm charts source code. 


## Code Organisation Strategy

You would maintain 3 Different Repos to maintain
  * Flux Fleet 
  * Project Deployment 
  * Project/App Source 

  1. **Flux Fleet Repository**  to manage organisation wide deployments to Kubernetes  with FluxCD. 
     This repository would contain 
       * Cluster Configurations for all your envvironments e.g. staging, production. You would bootstrap the clusters by pointing to this repo. 
       * Cluster Wide Infrastructure Components 
           e.g. Ingress Controllers, Repository Secrets etc.    
       * Project on boarding configurations aka. tenants spec. This is the spec that would point to a project repo for each tenant, fetch the sync manifests and deploy. 
     You could call it a  **flux-fleet** repository, which is managed typically by the SREs. [Fork this repo](https://github.com/lfs269/flux-fleet) to start seting up  fleet repo. 
     Who maintains Fleet Repo ==> Site Reliability Engineers / Devops/Platform Engineers. 

  2. Project Deployment Repository (Tenant). 
     This repository would contain, 
       * Flux Sync/Deployment Code. For example,
           * GitRepository 
           * HelmRepository  
           * Kustomization (FluxCD Deployments) 
           * HelmRelease
       * Helm Charts Source Code 
       * YAML Manifests as either 
           * Plain YAML
           * With Kustomize Overlays 
     This project repository serves as one tenant on the cluster. 
     Who maintains Fleet Repo ==> Developers + SREs. 

  3. Project/App Source Repository 
       * Application Source Code 
       * Self Explainatory 
       * Contains Source Code + Dockerfile etc. 
     Who maintains Fleet Repo ==> Developers.
        

## On Boarding a Project 

  1. SREs Setup Fleet Management of Kubernetes Clusters by 
     Creating  flux-fleet repo with
       * Cluster Definitions e.g. staging, qa, production
       * Cluster-wide  Infrastructure Deployment Code 
       * Projects (Tenants) Onboaring Scaffold 
     Bootstrapping Clusters with 
       * Git Source Integration with *flux-fleet* repo (its GitOps you know...)
       * Flux Controllers 
       * CRDs 
       * Policies : RBAC, Network Policy etc. 
       * Git Source Repo Interation (its GitOps you know...)
      
  2. Developers/SREs create Deplpoyment Repo with 
       * Flux Sync/Deployment Manifests
       * YAML Deployment + Kustomize Overlays 
       * Helm Charts 

  3. Project owners raise a On Boarding Request 
       * Provide Project Deployment Repository 

  4. SREs On Board the Project by 
       * Genrating Tenant RBAC 
       * Project On Boarding Manifests 
       
  5. FluxCD Reconciles the Cluster State by 
       * Syncing Project Deployment Code 
       * Genrating Flux Resources for the Project e.g.
           * GitRepository 
           * Kustomization 
           * HelmRelease 
       * Running Reconciliation for each of the Flux Resource with actual Kubernetes Cluster. 
          
EOF
fi

# Flux
mkdir -p flux/base

cat > flux/base/README.md <<EOF
## Kubernetes Deployment Manifests
This path is to add Deployment Manifests which are Synced by Flux to Deploy to a Kubernetes Environment.

Example of the resources you could add here,

Sources: 
  - GitRepository 
  - HelmRepository 
  - Bucket 

Deployment: 
  - HelmRelease 
  - Kustomization (Flux App Deployment)

Notification: 
  - Alert 
  - Provider
  - Receiver 

Image Automation: 
  - ImageRepository
  - ImagePolicy
  - ImageUpdateAutomation

EOF

# Flux overlays

for overlay in ${MY_OVERLAYS[*]}; do
  mkdir -p flux/overlays/$overlay

  cat > flux/overlays/$overlay/README.md <<EOF
## Kubernetes Deployment Manifests
This path is to add Kustomize Overlays for staging environemnt to flux sync  manifests defined in ../base.
If you add a patch file, ensure you update kustomization.yaml accordingly.
EOF

  cat > flux/overlays/$overlay/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
EOF
done

# Kustomize Setup

mkdir -p ${KUSTOMIZE_BASE}/base

cat > ${KUSTOMIZE_BASE}/base/README.md <<EOF
## Kubernetes Deployment Manifests
This path is to add Kubernetes Manifests YAML.  

Examples of resources that you would add here, 
  - Deployment 
  - Service 
  - StatefulSet 
  - DaemonSet 
  - Job
  - CronJob  
  - PersistentVolumeClaim

In fact it could be any resource that you would apply to kubernetes. 

EOF

for overlay in ${MY_OVERLAYS[*]}; do
  mkdir -p ${KUSTOMIZE_BASE}/overlays/$overlay

cat > ${KUSTOMIZE_BASE}/overlays/$overlay/README.md <<EOF
## Kubernetes Deployment Manifests
This path is to add Kustomize Overlays for staging environemnt to  manifests defined in ../base. 
If you add a patch file, ensure you update kustomization.yaml accordingly. 
EOF

cat > ${KUSTOMIZE_BASE}/overlays/$overlay/kustomization.yaml <<EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
EOF
done

# Helm 
mkdir -p helm/charts

cat > helm/charts/README.md <<EOF
## Helm Charts 
Add your helm charts here. 
EOF



