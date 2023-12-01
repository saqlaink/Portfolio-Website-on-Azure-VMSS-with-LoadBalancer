# Portfolio Website on Azure VMSS with Load Balancer

## Project Overview

### Objectives

This project aims to create a robust and scalable infrastructure on Microsoft Azure to host a dynamic portfolio website. The primary objectives include:

- **Azure VMSS Setup:** Utilizing Azure Virtual Machine Scale Sets to automate the scaling of VM instances based on fluctuating demand. This ensures the website can handle varying levels of traffic efficiently without manual intervention.
- **Load Balancer Configuration:** Implementing an Azure Load Balancer to evenly distribute incoming web traffic among multiple VM instances. This ensures optimal performance, resilience against traffic spikes, and redundancy in case of instance failures.
- **High Availability:** Ensuring the website remains continuously accessible by effectively distributing traffic among healthy VM instances. This minimizes downtime and enhances the overall reliability of the deployed portfolio website.

### Components

#### Azure VMSS

The project relies on Azure Virtual Machine Scale Sets for managing and scaling a group of identical VMs:

- **Dynamic Scaling:** Configuring auto-scaling rules based on key metrics like CPU utilization or incoming traffic patterns. This allows the infrastructure to adapt to changing workloads, automatically scaling up or down as needed.
- **Customization:** Defining specific VM specifications such as CPU, memory, disk, and OS configurations. This enables the creation of standardized instances tailored for hosting the portfolio website.

#### Azure Load Balancer

The Azure Load Balancer plays a pivotal role in the infrastructure:

- **Traffic Distribution:** Equitably distributing incoming web requests across all healthy VM instances within the Virtual Machine Scale Set. This load balancing ensures optimal utilization of resources and enhances the website's responsiveness.
- **Health Probes:** Continuously monitoring the health and availability of individual VM instances. Unhealthy instances are automatically excluded from receiving traffic until they are restored to a healthy state.

### Terraform Deployment

The infrastructure setup can be orchestrated using Terraform, an infrastructure as code tool:

- **Infrastructure as Code:** Utilize Terraform configurations (included in the repository) to define Azure resources, VMSS, Load Balancer, and associated configurations.
- **Deployment Automation:** Terraform allows for reproducible and automated infrastructure deployment, ensuring consistency across environments.
