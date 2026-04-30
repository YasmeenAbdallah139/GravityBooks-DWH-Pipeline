/*
--------------------------------------------------------------------------------
Project: Gravity Books Data Warehouse (DWH)
Description: Schema definition for Star Schema including Dimensions and Fact tables.
Script Date: 4/30/2026
--------------------------------------------------------------------------------
*/

-- 1. Create the Database (Simplified)
USE [master];
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'gravity_books_DWH')
BEGIN
    CREATE DATABASE [gravity_books_DWH];
END
GO

USE [gravity_books_DWH];
GO

-- 2. Create Dimension Tables
--------------------------------------------------------------------------------

-- Author Dimension
CREATE TABLE [dbo].[author](
	[author_sk] [int] IDENTITY(1,1) NOT NULL,
	[author_bk] [int] NULL,
	[author_name] [nvarchar](400) NULL,
    PRIMARY KEY CLUSTERED ([author_sk] ASC)
);
GO

-- Address Dimension
CREATE TABLE [dbo].[Dim_address](
	[address_sk] [int] IDENTITY(1,1) NOT NULL,
	[address_bk] [int] NULL,
	[country_bk] [int] NULL,
	[status_bk] [int] NULL,
	[street_num] [varchar](10) NULL,
	[street_name] [varchar](200) NULL,
	[city] [varchar](100) NULL,
	[country_name] [varchar](200) NULL,
	[address_Status] [varchar](30) NULL,
	[start_date] [datetime] NULL,
	[SSC] [int] NULL,
	[is_current] [tinyint] NULL,
	[end_date] [datetime] NULL,
    PRIMARY KEY CLUSTERED ([address_sk] ASC)
);
GO

-- Book Dimension
CREATE TABLE [dbo].[Dim_Book](
	[Book_sk] [int] IDENTITY(1,1) NOT NULL,
	[Book_bk] [int] NULL,
	[title] [nvarchar](400) NULL,
	[isbn13] [nvarchar](13) NULL,
	[num_pages] [int] NULL,
	[language_bk] [int] NULL,
	[language_code] [nvarchar](10) NULL,
	[language_name] [nvarchar](50) NULL,
	[Publisher_bk] [int] NULL,
	[publisher_name] [nvarchar](1000) NULL,
    PRIMARY KEY CLUSTERED ([Book_sk] ASC)
);
GO

-- Customer Dimension
CREATE TABLE [dbo].[Dim_customer](
	[customer_sk] [int] IDENTITY(1,1) NOT NULL,
	[customer_bk] [int] NULL,
	[first_name] [nvarchar](200) NULL,
	[last_name] [nvarchar](200) NULL,
	[email] [nvarchar](200) NULL,
	[start_date] [datetime] NULL,
	[end_date] [datetime] NULL,
	[is_current] [tinyint] NULL,
	[SSC] [int] NULL,
    PRIMARY KEY CLUSTERED ([customer_sk] ASC)
);
GO

-- Order Status Dimension
CREATE TABLE [dbo].[Dim_order_status](
	[status_sk] [int] IDENTITY(1,1) NOT NULL,
	[status_bk] [int] NULL,
	[status_value] [varchar](20) NULL,
    PRIMARY KEY CLUSTERED ([status_sk] ASC)
);
GO

-- Shipping Dimension
CREATE TABLE [dbo].[Dim_shipping](
	[shipping_sk] [int] IDENTITY(1,1) NOT NULL,
	[shipping_bk] [int] NULL,
	[method_name] [varchar](100) NULL,
	[cost] [decimal](6, 2) NULL,
    PRIMARY KEY CLUSTERED ([shipping_sk] ASC)
);
GO

-- Date Dimension
CREATE TABLE [dbo].[DimDate](
	[DateSK] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Day] [char](2) NOT NULL,
	[DaySuffix] [varchar](4) NOT NULL,
	[DayOfWeek] [varchar](9) NOT NULL,
	[DOWInMonth] [tinyint] NOT NULL,
	[DayOfYear] [int] NOT NULL,
	[WeekOfYear] [tinyint] NOT NULL,
	[WeekOfMonth] [tinyint] NOT NULL,
	[Month] [char](2) NOT NULL,
	[MonthName] [varchar](9) NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[QuarterName] [varchar](6) NOT NULL,
	[Year] [char](4) NOT NULL,
	[StandardDate] [varchar](10) NULL,
	[HolidayText] [varchar](50) NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateSK] ASC)
);
GO

-- 3. Create Bridge Tables (Many-to-Many Relationships)
--------------------------------------------------------------------------------

CREATE TABLE [dbo].[book_author_bridge](
	[Book_sk] [int] NOT NULL,
	[author_sk] [int] NOT NULL,
    PRIMARY KEY CLUSTERED ([Book_sk] ASC, [author_sk] ASC)
);
GO

CREATE TABLE [dbo].[customer_address_bridge](
	[customer_sk] [int] NOT NULL,
	[address_sk] [int] NOT NULL,
    PRIMARY KEY CLUSTERED ([customer_sk] ASC, [address_sk] ASC)
);
GO

-- 4. Create Fact Tables
--------------------------------------------------------------------------------

-- Order Lifecycle Fact
CREATE TABLE [dbo].[Fact_order_lifecycle](
	[orde_lifecycle_fk] [int] IDENTITY(1,1) NOT NULL,
	[order_bk] [int] NULL,
	[customer_sk] [int] NULL,
	[shipping_sk] [int] NULL,
	[status_sk] [int] NULL,
	[received_date_sk] [int] NULL,
	[pending_delivery_date_sk] [int] NULL,
	[in_progress_date_sk] [int] NULL,
	[delivered_date_sk] [int] NULL,
	[cancelled_date_sk] [int] NULL,
	[returned_date_sk] [int] NULL,
	[days_to_ship] [int] NULL,
	[days_to_deliver] [int] NULL,
	[total_days_to_deliver] [int] NULL,
	[is_complete] [tinyint] NULL,
	[is_cancelled] [tinyint] NULL,
    CONSTRAINT [PK_Fact_order_lifecycle] PRIMARY KEY CLUSTERED ([orde_lifecycle_fk] ASC)
);
GO

-- Sales Fact
CREATE TABLE [dbo].[Fact_sales](
	[sales_sk] [int] IDENTITY(1,1) NOT NULL,
	[order_line_bk] [nchar](10) NULL,
	[order_bk] [int] NULL,
	[customer_sk] [int] NULL,
	[Book_sk] [int] NULL,
	[shipping_sk] [int] NULL,
	[order_date_sk] [int] NULL,
	[price] [decimal](18, 2) NULL,
    CONSTRAINT [PK_Fact_sales] PRIMARY KEY CLUSTERED ([sales_sk] ASC)
);
GO

-- 5. Create Indexes for Performance
--------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX [IDX_DimDate_Date] ON [dbo].[DimDate] ([Date] ASC);
CREATE NONCLUSTERED INDEX [IDX_DimDate_Year] ON [dbo].[DimDate] ([Year] ASC);
-- (Add other indexes here if needed)
GO

-- 6. Add Foreign Key Constraints
--------------------------------------------------------------------------------

-- Bridges
ALTER TABLE [dbo].[book_author_bridge] WITH CHECK ADD FOREIGN KEY([author_sk]) REFERENCES [dbo].[author] ([author_sk]);
ALTER TABLE [dbo].[book_author_bridge] WITH CHECK ADD FOREIGN KEY([Book_sk]) REFERENCES [dbo].[Dim_Book] ([Book_sk]);

ALTER TABLE [dbo].[customer_address_bridge] WITH CHECK ADD FOREIGN KEY([address_sk]) REFERENCES [dbo].[Dim_address] ([address_sk]);
ALTER TABLE [dbo].[customer_address_bridge] WITH CHECK ADD FOREIGN KEY([customer_sk]) REFERENCES [dbo].[Dim_customer] ([customer_sk]);

-- Fact Sales
ALTER TABLE [dbo].[Fact_sales] WITH CHECK ADD FOREIGN KEY([Book_sk]) REFERENCES [dbo].[Dim_Book] ([Book_sk]);
ALTER TABLE [dbo].[Fact_sales] WITH CHECK ADD FOREIGN KEY([customer_sk]) REFERENCES [dbo].[Dim_customer] ([customer_sk]);
ALTER TABLE [dbo].[Fact_sales] WITH CHECK ADD FOREIGN KEY([order_date_sk]) REFERENCES [dbo].[DimDate] ([DateSK]);
ALTER TABLE [dbo].[Fact_sales] WITH CHECK ADD FOREIGN KEY([shipping_sk]) REFERENCES [dbo].[Dim_shipping] ([shipping_sk]);

-- Fact Lifecycle
ALTER TABLE [dbo].[Fact_order_lifecycle] WITH CHECK ADD FOREIGN KEY([customer_sk]) REFERENCES [dbo].[Dim_customer] ([customer_sk]);
ALTER TABLE [dbo].[Fact_order_lifecycle] WITH CHECK ADD FOREIGN KEY([shipping_sk]) REFERENCES [dbo].[Dim_shipping] ([shipping_sk]);
ALTER TABLE [dbo].[Fact_order_lifecycle] WITH CHECK ADD FOREIGN KEY([status_sk]) REFERENCES [dbo].[Dim_order_status] ([status_sk]);
ALTER TABLE [dbo].[Fact_order_lifecycle] WITH CHECK ADD FOREIGN KEY([received_date_sk]) REFERENCES [dbo].[DimDate] ([DateSK]);
GO