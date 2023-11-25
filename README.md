# Portfolio Website on Azure VMSS with Load Balancer

This project showcases the deployment of a portfolio website on an Azure Virtual Machine Scale Set (VMSS) with a Load Balancer, ensuring scalability, high availability, and efficient distribution of incoming traffic.

## Project Overview

### Objectives

The primary objective of this project is to deploy a resilient infrastructure on Azure for hosting a portfolio website. Key features include:

- **Azure VMSS Setup:** Utilizing Virtual Machine Scale Sets for automatic scaling of VM instances based on demand.
- **Load Balancer Configuration:** Distributing incoming web traffic across multiple VM instances for improved performance and redundancy.
- **High Availability:** Ensuring continuous availability of the website by distributing traffic among healthy VM instances.

### Components

#### Azure VMSS

The deployment utilizes VMSS to manage a set of identical VMs:

- **Scaling:** Configuring auto-scaling rules based on metrics like CPU utilization or incoming traffic.
- **Customization:** Defining VM specifications, OS configurations, and other necessary resources.

#### Azure Load Balancer

The Load Balancer helps evenly distribute incoming network traffic:

- **Traffic Distribution:** Distributing incoming requests across healthy VM instances within the VMSS.
- **Health Probes:** Monitoring the health of VMs and directing traffic only to healthy instances.
