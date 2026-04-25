# 📄 Invoice PDF Generation App (LWC + Apex)

## 🚀 Overview

This project is a complete business use-case implementation for generating invoices from Opportunities in Salesforce.

It allows users to:

* Select an Opportunity
* Review associated Products (Opportunity Line Items)
* Edit quantities and pricing
* Generate an Invoice with Line Items
* Automatically generate and download a PDF
* Navigate to the created Invoice record

---

## 🧩 Features Implemented

### 🔹 Multi-Step LWC Form

* Step 1: Display Opportunity details
* Step 2: Edit line items (Quantity, Price, Total)
* Dynamic UI using template looping
* Progress indicator for navigation

---

### 🔹 Data Fetching

* Used **@wire** to fetch Opportunity and related Products
* Apex method: `getOpportunityWithProducts`

---

### 🔹 Line Item Management

* Editable quantity and price fields
* Real-time total calculation per row
* Grand total calculated using getter

---

### 🔹 Invoice Creation (Single Transaction)

* Apex method: `createInvoice`
* Creates:

  * Invoice Header (`Invoice__c`)
  * Invoice Line Items (`Invoice_Line__c`)
* Uses **Savepoint & Rollback** for transaction safety

---

### 🔹 PDF Generation & Download

* Visualforce page rendered as PDF
* Apex method: `generateAndAttachPdf`
* Stores PDF using **ContentVersion**
* Auto-download after generation

---

### 🔹 Navigation

* Uses **NavigationMixin**
* Redirects user to newly created Invoice record

---

### 🔹 Error Handling

* Toast messages for success and failure
* Server-side validation for line items
* Input validation in LWC

---

### 🔹 UI/UX

* Built using **Salesforce Lightning Design System (SLDS)**
* Responsive layout
* Loading spinner during operations


## ⚙️ Deployment Steps (Using Salesforce CLI)

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd <your-project-folder>
```

---

### 2. Create a Scratch Org

```bash
sf org create scratch -f config/project-scratch-def.json -a InvoiceApp -s
```

---

### 3. Deploy Source to Org

```bash
sf project deploy start
```

---

### 4. Open the Org

```bash
sf org open
```

---



## 🧪 Test Data Setup

1. Create an **Account**
2. Create an **Opportunity**
3. Add **Products** to Opportunity (Opportunity Line Items)
4. Ensure Pricebook is active

---

## ▶️ How to Use

1. Go to an Opportunity record
2. Click **"Create Invoice" Quick Action**
3. Step 1:

   * Review Opportunity details
4. Step 2:

   * Update Quantity & Price
   * View calculated totals
5. Click **Save**
6. System will:

   * Create Invoice
   * Generate PDF
   * Download PDF
   * Redirect to Invoice record
  ## 🔑 Access & Login Method

This project is intended to be deployed and tested in a Salesforce Scratch Org using Salesforce CLI.

### 🚀 Recommended Approach (No Manual Credentials Required)

After deploying the source code, open the scratch org using:

```bash id="8xqv3m"
sf org open
```

This will automatically log you into the assigned scratch org and allow you to test the application.

---

### 📌 Note

No manual username or password is required. Authentication is handled automatically via Salesforce CLI session.



