# Gravity Book Store - Data Warehouse Project

A comprehensive **Business Intelligence solution** for a book store, implementing a complete data warehouse using Microsoft's BI stack (SQL Server, SSIS, SSAS, Power BI).

---

## 📊 Project Overview

This project demonstrates a full end-to-end data warehouse implementation for an online book store business. It includes dimensional modeling, ETL processes, OLAP cubes, and analytical reporting capabilities.

### Business Domain
- **Industry**: E-commerce (Book Retail)
- **Purpose**: Enable data-driven decision making through comprehensive sales, customer, and inventory analytics
- **Scope**: Order transactions, customer management, book catalog, shipping operations

---

## 🏗️ Architecture

### Data Warehouse Model

![Data Warehouse Model](docs/GBS_DWH_Model.png)

The data warehouse implements a **Star Schema** design with:
- **1 Fact Table**: `fact_table_gravity_book_store`
- **10 Dimension Tables**: Books, Customers, Authors, Addresses, Shipping Methods, Order History, Date, Time
- **2 Bridge Tables**: Book-Author, Customer-Address (for many-to-many relationships)

### Source Database Schema

![Source Database](docs/GBS_Database.jpg)

---

## 🛠️ Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Database** | SQL Server | Data warehouse storage |
| **ETL** | SSIS (SQL Server Integration Services) | Extract, Transform, Load processes |
| **OLAP** | SSAS (SQL Server Analysis Services) | Multidimensional analysis |
| **Reporting** | Power BI | Dashboards and analytics |

---

## 📁 Project Structure

```
Gravity_Book_Store_DWH/
├── README.md                          # This file
├── .gitignore                         # Git ignore rules
├── docs/                              # Documentation
│   ├── GBS_DWH_Model.png             # Data warehouse model diagram
│   ├── GBS_Database.jpg              # Source database diagram
│   └── DW_Project.docx               # Detailed project documentation
├── database/                          # Database scripts
│   └── GBS_Schema.sql                # Complete DDL for all tables
├── reports/                           # Analytics & Reports
│   └── DWH_Analysis.pbix             # Power BI analysis file
└── etl/                              # ETL processes
    └── ssis/                         # SSIS packages
        ├── P1_Dim_Author.dtsx
        ├── P2_Dim_Shipping_Method.dtsx
        ├── P3_Dim_Order_History.dtsx
        ├── P4_Dim_Book.dtsx
        ├── P5_Dim_Bridge_Book_Author.dtsx
        ├── P6_Dim_Address.dtsx
        ├── P7_Dim_Customer.dtsx
        ├── P8_Dim_Bridge_Customer_Address.dtsx
        └── P9_Fact_Table.dtsx
```

---

## 📐 Database Schema

### Fact Table

#### `fact_table_gravity_book_store`
Stores transactional data for book orders.

**Key Measures**:
- `book_price` - Price of the book
- `shipping_cost` - Shipping cost for the order

**Foreign Keys**:
- `book_key_sk` → dim_book
- `cus_key_sk` → dim_customer
- `method_id_pk` → dim_shipping_method
- `history_key_sk` → dim_order_history
- `date_sk` → Dim_Date
- `time_sk` → Dim_Time

**Degenerate Dimensions**:
- `order_id_dd` - Order ID
- `line_id_dd` - Line item ID

---

### Dimension Tables

#### 1. `dim_book` (Type 1 SCD)
Book catalog with denormalized publisher and language information.

**Key Attributes**:
- Book title, ISBN-13, number of pages, publication date
- Language (code and name)
- Publisher information

#### 2. `dim_author`
Author information with many-to-many relationship to books via bridge table.

#### 3. `dim_bridge_book_author`
Bridge table handling multiple authors per book.

#### 4. `dim_customer` (Type 1 SCD)
Customer master data.

**Attributes**:
- First name, last name, email

#### 5. `dim_address` (Type 2 SCD)
Address information with historical tracking.

**SCD Type 2 Attributes**:
- `start_date` - When this address version became active
- `end_date` - When this address version expired
- `IsCurrent` - Flag indicating current record

**Attributes**:
- Street number, street name, city
- Country information

#### 6. `dim_bridge_customer_address`
Bridge table for customer-address many-to-many relationship.

**Attributes**:
- `address_status` - Type of address (billing, shipping, etc.)

#### 7. `dim_shipping_method`
Shipping method lookup dimension.

#### 8. `dim_order_history` (Type 1 SCD)
Order status tracking.

**Attributes**:
- Status value and status date

#### 9. `Dim_Date`
Comprehensive date dimension with calendar attributes.

**Date Range**: 2020-01-01 to 2030-01-01

**Key Features**:
- ✅ Full calendar hierarchy (day, week, month, quarter, year)
- ✅ US holidays (New Year's, Independence Day, Thanksgiving, Christmas, etc.)
- ✅ Egyptian holidays (Revolution days, Sinai Liberation, Eid al-Fitr, Eid al-Adha, etc.)
- ✅ Bilingual holiday names (English & Arabic)
- ✅ Day of week, week of month, day of year calculations

**Sample Attributes**:
- `Date_SK` (PK) - Format: YYYYMMDD
- `DayOfWeek`, `MonthName`, `Quarter`, `Year`
- `Holiday_name_en`, `Holiday_name_ar`

#### 10. `Dim_Time`
Time dimension with second-level granularity.

**Granularity**: 86,400 records (every second of the day)

**Attributes**:
- 12-hour and 24-hour formats
- Hour, Minute, Second
- AM/PM indicator

---

## 🔄 ETL Process

### SSIS Package Execution Order

The ETL process is organized into 9 SSIS packages, numbered for sequential execution:

1. **P1_Dim_Author** - Load author dimension
2. **P2_Dim_Shipping_Method** - Load shipping methods
3. **P3_Dim_Order_History** - Load order history
4. **P4_Dim_Book** - Load book dimension
5. **P5_Dim_Bridge_Book_Author** - Load book-author relationships
6. **P6_Dim_Address** - Load address dimension (with Type 2 SCD logic)
7. **P7_Dim_Customer** - Load customer dimension
8. **P8_Dim_Bridge_Customer_Address** - Load customer-address relationships
9. **P9_Fact_Table** - Load fact table (must run last)

### Design Patterns

- **Dimension-First Loading**: All dimensions loaded before fact table
- **Bridge Tables**: Loaded after their parent dimensions
- **Type 2 SCD**: Implemented in `dim_address` for historical tracking
- **Surrogate Keys**: Auto-generated using IDENTITY columns
- **Business Keys**: Preserved for reference and lookups

---

## 🎯 Business Questions Answered

This data warehouse enables analysis of:

### Sales Analytics
- Total revenue by time period (day/month/quarter/year)
- Best-selling books and authors
- Average book price by publisher or language
- Sales trends and seasonal patterns

### Customer Analytics
- Top customers by revenue
- Customer distribution by geography
- Customer lifetime value
- Address change history

### Operational Analytics
- Shipping cost analysis by method
- Order status distribution
- Order processing time metrics
- Peak ordering times

### Time-Based Analysis
- Holiday impact on sales (Egyptian & US holidays)
- Day-of-week patterns
- Intraday sales patterns
- Year-over-year comparisons

---

## 🚀 Getting Started

### Prerequisites

- SQL Server 2019 or later
- SQL Server Integration Services (SSIS)
- SQL Server Analysis Services (SSAS) - Optional
- Power BI Desktop - For viewing reports
- Visual Studio with SQL Server Data Tools (SSDT)

### Installation Steps

1. **Create Database**
   ```sql
   CREATE DATABASE GBS;
   GO
   ```

2. **Execute Schema Script**
   ```bash
   # Run the DDL script to create all tables
   sqlcmd -S your_server -d GBS -i database/GBS_Schema.sql
   ```

3. **Configure SSIS Packages**
   - Open SSIS packages in Visual Studio
   - Update connection managers with your server details
   - Configure source database connection

4. **Execute ETL Packages**
   - Run packages in order (P1 through P9)
   - Monitor execution for errors
   - Verify data loaded correctly

5. **Open Power BI Report**
   - Open `reports/DWH_Analysis.pbix` in Power BI Desktop
   - Update data source connection to your SQL Server
   - Refresh data

---

## 📊 Data Warehouse Features

### ✅ Implemented Features

- **Star Schema Design** - Optimized for analytical queries
- **Slowly Changing Dimensions** - Type 1 and Type 2 implementations
- **Bridge Tables** - Proper handling of many-to-many relationships
- **Comprehensive Date Dimension** - With holidays and calendar attributes
- **Time Dimension** - Second-level granularity for intraday analysis
- **Denormalization** - Strategic denormalization for query performance
- **Surrogate Keys** - All dimensions use surrogate keys
- **ETL Framework** - Complete SSIS package suite
- **OLAP Cube** - Multidimensional analysis capability
- **Power BI Reports** - Interactive dashboards

### 🎨 Design Highlights

- **Bilingual Support** - Holiday names in English and Arabic
- **Cultural Relevance** - Egyptian and US holidays included
- **Scalability** - 10-year date range (2020-2030)
- **Performance** - Indexed for optimal query performance
- **Maintainability** - Well-organized and documented code

---

## 📈 Sample Queries

### Top 10 Best-Selling Books
```sql
SELECT TOP 10
    b.title,
    b.publisher_name,
    COUNT(f.fact_table_sk) AS total_orders,
    SUM(f.book_price) AS total_revenue
FROM fact_table_gravity_book_store f
INNER JOIN dim_book b ON f.book_key_sk = b.book_key_sk
GROUP BY b.title, b.publisher_name
ORDER BY total_revenue DESC;
```

### Sales by Month
```sql
SELECT 
    d.Year,
    d.MonthName,
    COUNT(f.fact_table_sk) AS total_orders,
    SUM(f.book_price + f.shipping_cost) AS total_revenue
FROM fact_table_gravity_book_store f
INNER JOIN Dim_Date d ON f.date_sk = d.Date_SK
GROUP BY d.Year, d.Month, d.MonthName
ORDER BY d.Year, d.Month;
```

### Holiday Impact Analysis
```sql
SELECT 
    d.Holiday_name_en,
    COUNT(f.fact_table_sk) AS orders_on_holiday,
    AVG(f.book_price) AS avg_book_price
FROM fact_table_gravity_book_store f
INNER JOIN Dim_Date d ON f.date_sk = d.Date_SK
WHERE d.Holiday_name_en <> 'No Holiday'
GROUP BY d.Holiday_name_en
ORDER BY orders_on_holiday DESC;
```

---

## 📚 Additional Documentation

- **Detailed Documentation**: See [docs/DW_Project.docx](docs/DW_Project.docx) for comprehensive project documentation
- **Power BI Report**: Open [reports/DWH_Analysis.pbix](reports/DWH_Analysis.pbix) for interactive dashboards
- **SQL Scripts**: All DDL and data population scripts in [database/GBS_Schema.sql](database/GBS_Schema.sql)

---

## 🔧 Configuration Notes

### Connection Managers
The SSIS packages use connection managers that need to be configured:
- **Source Database**: Configure connection to your source database
- **Target Database**: Configure connection to the GBS data warehouse

### Date Dimension
The date dimension is pre-populated from 2020-01-01 to 2030-01-01. To extend the range:
```sql
-- Modify these variables in the script
DECLARE @StartDate datetime = '2020-01-01';
DECLARE @EndDate datetime = '2035-01-01'; -- Extend to 2035
```

---

## 📝 License

This project is available for educational and portfolio purposes.

---

## 🙏 Acknowledgments

- Microsoft SQL Server documentation
- Kimball Group dimensional modeling methodology
- Data warehouse design best practices from industry standards

---

## 📧 Contact

For questions or feedback about this project, please open an issue in this repository.

---

**Project Type**: Data Warehouse & Business Intelligence  
**Domain**: E-commerce (Book Store)  
**Technologies**: SQL Server, SSIS, SSAS, Power BI  
**Schema**: Star Schema with Type 1 & Type 2 SCDs
