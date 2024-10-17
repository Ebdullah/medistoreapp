# Medical Store Management System
This is a web-based Medical Store Management System built with Ruby on Rails. It handles multiple branches, stock management, customer purchases, employee access, and customer notifications.
## Features
- User roles: Super Admin, Admin, Cashier, and Customer.
- Manage branches, stock, and employees.
- Customer purchases and notifications.
- Inter-branch stock transfers.
- Transaction history and audit logs.
- **Additional Features**:
  - Pagination for managing large datasets.
  - Country code integration for customer contact details.
  - Online payment integration.
  - Medicine search functionality with Select2.
## Requirements
- **Ruby version**: `3.0.2`
- **Rails version**: `7.1.4`
- **Database**: PostgreSQL
## Setup Instructions
### 1. Clone the repository
git clone https://github.com/Ebdullah/medistoreapp.git
cd myapp
### 2. Install dependencies
bash
Copy code
bundle install
### 3. Setup the database
bash
Copy code
rails db:create
rails db:migrate
### 4. Seed the database (optional)
bash
Copy code
rails db:seed
### 5. Start the server
bash
Copy code
rails server
Navigate to http://localhost:3000 in your browser to see the application.
