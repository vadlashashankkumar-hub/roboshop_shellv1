## RoboShop Shell v1

This project uses Bash scripts to provision and configure the services in a RoboShop deployment. It includes scripts for the frontend, cart, catalogue, user, payment, shipping, MongoDB, MySQL, Redis, and RabbitMQ.

The `roboshop-v1.sh` script can create EC2 instances for the requested services and update Route 53 records. Service-specific scripts handle their respective setup.

### Prerequisites

- An AWS account with permissions to manage EC2 instances and Route 53 records
- AWS CLI installed and configured with credentials for that account
- The required AMI, security groups, and Route 53 hosted zone configured
- A Linux environment with Bash

### Usage

Clone the repository and run the deployment script with the service names you want to provision:

```bash
git clone https://github.com/vadlashashankkumar-hub/roboshop_shellv1.git
cd roboshop_shellv1

bash roboshop-v1.sh frontend cart catalogue

Services
- Frontend
- Cart
- Catalogue
- User
- Payment
- Shipping
- MongoDB
- MySQL
- Redis
- RabbitMQ

