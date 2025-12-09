# Gravity Book Store - Data Warehouse Project

A comprehensive **Business Intelligence solution** for a book store, implementing a complete data warehouse using Microsoft's BI stack.

---

## 📊 Project Overview

This project demonstrates a full end-to-end data warehouse implementation for an online book store business, including dimensional modeling, ETL processes, and analytical reporting.


---

## 🏗️ Architecture

### Data Warehouse Model
![Data Warehouse Model](docs/GBS_DWH_Model.png)

### Source Database Schema
![Source Database](docs/GBS_Database.jpg)

**Schema Design**: Snowflake Schema with 1 Fact Table, 10 Dimension Tables, and 2 Bridge Tables

---

## 🛠️ Technology Stack

| Component | Technology |
|-----------|-----------|
| **Database** | SQL Server |
| **ETL** | SSIS (SQL Server Integration Services) |
| **Reporting** | Power BI |


---

## 📐 Database Schema

### Fact Table
- **fact_table_gravity_book_store**: Order transactions with book prices and shipping costs

### Dimension Tables
1. **dim_book** - Book catalog (title, ISBN, publisher, language)
2. **dim_author** - Author information
3. **dim_customer** - Customer master data
4. **dim_address** - Address with historical tracking (Type 2 SCD)
5. **dim_shipping_method** - Shipping methods
6. **dim_order_history** - Order status tracking
7. **Dim_Date** - Date dimension (2020-2030) with US & Egyptian holidays
8. **Dim_Time** - Time dimension (second-level granularity)
9. **dim_bridge_book_author** - Book-Author relationships
10. **dim_bridge_customer_address** - Customer-Address relationships

---

## 🔄 ETL Process

The ETL process consists of 9 SSIS packages executed sequentially:
1. Load dimension tables (P1-P7)
2. Load bridge tables (P5, P8)
3. Load fact table (P9)

---

## 🎯 Key Features

- ✅ Snowflake Schema design optimized for analytics
- ✅ Slowly Changing Dimensions (Type 1 & Type 2)
- ✅ Comprehensive date dimension with bilingual holidays
- ✅ Complete ETL pipeline with SSIS
- ✅ Power BI dashboards

---

## 🚀 Getting Started

### Prerequisites
- SQL Server 2019+
- SQL Server Integration Services (SSIS)
- Power BI Desktop
- Visual Studio with SQL Server Data Tools

### Installation
1. Create database: `CREATE DATABASE GBS;`
2. Execute schema: `sqlcmd -S server -d GBS -i database/GBS_Schema.sql`
3. Configure SSIS connection managers
4. Run ETL packages (P1 through P9)
5. Open Power BI report and refresh data

---