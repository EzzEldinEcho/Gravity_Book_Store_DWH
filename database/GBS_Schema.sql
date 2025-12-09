use GBS

-----------------------------------------------------------------------------------------------------

create table dim_book
(
    book_key_sk int identity(1,1) primary key, 
    book_id_bk int not null, 
    title varchar(400),
    isbn13 varchar(13),
    num_page int,
    publicationDate date,
    lang_id_bk int not null,
    lang_Code nvarchar(8),
    lang_name nvarchar(50),
    publisher_id int not null,
    publisher_name nvarchar(1000)


)

-----------------------------------------------------------------------------------------------------

create table dim_author
(
    author_id_pk int primary key,
    author_name varchar(400)
)

------------------------------------------------------------------------------------------------------

create table dim_bridge_book_author
(
    book_key_sk int,
    author_id int

    constraint pk primary key (book_key_sk , author_id),
    constraint fk1 foreign key (book_key_sk) references dim_book(book_key_sk),
    constraint fk2 foreign key (author_id) references dim_author(author_id_pk)
)

-----------------------------------------------------------------------------------------------------

create table dim_shipping_method
(
   method_id_pk int primary key,
   method_name nvarchar(100),
)

-----------------------------------------------------------------------------------------------------

create table dim_order_history
(
    history_key_sk int identity(1,1) primary key,
    history_id_bk int not null,
    status_id_bk int not null,
    status_value varchar(20),
    status_date datetime
)

-----------------------------------------------------------------------------------------------------

/*
Brief : This script creates and populates the Dim_Date table with dates, 
        attributes (day, month, quarter, year, etc.), and common holidays. 
								- You can customize the
		 ********************** @StartDate and @EndDate ****************************
								 variables to set the 
							   range of dates generated. 

Author: Mohamed Roshdy
Date  : 10-02-2025
*/



BEGIN TRY
 DROP TABLE [Dim_Date];
END TRY
BEGIN CATCH
 -- DO NOTHING
END CATCH;

CREATE TABLE [dbo].[Dim_Date] (
 [Date_SK] int NOT NULL, --  YYYYMMDD
 [Date] date NOT NULL,
 [Day] char(2) NOT NULL,
 [DaySuffix] varchar(4) NOT NULL,
 [DayOfWeek] varchar(9) NOT NULL,
 [DOWInMonth] tinyint NOT NULL,
 [DayOfYear] int NOT NULL,
 [WeekOfYear] tinyint NOT NULL,
 [WeekOfMonth] tinyint NOT NULL,
 [Month] char(2) NOT NULL,
 [MonthName] varchar(9) NOT NULL,
 [Quarter] tinyint NOT NULL,
 [QuarterName] varchar(6) NOT NULL,
 [Year] char(4) NOT NULL,
 [StandardDate] varchar(10) NULL,
 [Holiday_name_en] varchar(50) NULL,
 CONSTRAINT [PK_Dim_Date] PRIMARY KEY CLUSTERED ([Date_SK])
);

TRUNCATE TABLE Dim_Date;

DECLARE @tmpDOW TABLE (DOW INT, Cntr INT);
INSERT INTO @tmpDOW(DOW, Cntr) VALUES (1,0),(2,0),(3,0),(4,0),(5,0),(6,0),(7,0);

DECLARE @StartDate datetime = '2020-01-01';
DECLARE @EndDate datetime = '2030-01-01'; -- non-inclusive
DECLARE @Date datetime = @StartDate;
DECLARE @WDofMonth INT;
DECLARE @CurrentMonth INT = MONTH(@StartDate);

WHILE @Date < @EndDate
BEGIN
 IF MONTH(@Date) <> @CurrentMonth
 BEGIN
  SET @CurrentMonth = MONTH(@Date);
  UPDATE @tmpDOW SET Cntr = 0;
 END

 UPDATE @tmpDOW SET Cntr = Cntr + 1 WHERE DOW = DATEPART(WEEKDAY, @Date);
 SELECT @WDofMonth = Cntr FROM @tmpDOW WHERE DOW = DATEPART(WEEKDAY, @Date);

 INSERT INTO Dim_Date (
  Date_SK, Date, Day, DaySuffix, DayOfWeek, DOWInMonth, DayOfYear,
  WeekOfYear, WeekOfMonth, Month, MonthName, Quarter, QuarterName, Year
 )
 SELECT 
  CONVERT(varchar, @Date, 112),
  @Date,
  RIGHT('0' + CAST(DAY(@Date) AS varchar), 2),
  CASE 
   WHEN DAY(@Date) IN (11,12,13) THEN CAST(DAY(@Date) AS varchar) + 'th'
   WHEN RIGHT(CAST(DAY(@Date) AS varchar),1) = '1' THEN CAST(DAY(@Date) AS varchar) + 'st'
   WHEN RIGHT(CAST(DAY(@Date) AS varchar),1) = '2' THEN CAST(DAY(@Date) AS varchar) + 'nd'
   WHEN RIGHT(CAST(DAY(@Date) AS varchar),1) = '3' THEN CAST(DAY(@Date) AS varchar) + 'rd'
   ELSE CAST(DAY(@Date) AS varchar) + 'th'
  END,
  DATENAME(WEEKDAY, @Date),
  @WDofMonth,
  DATEPART(DAYOFYEAR, @Date),
  DATEPART(WEEK, @Date),
  DATEPART(WEEK, @Date) + 1 - DATEPART(WEEK, CAST(CAST(MONTH(@Date) AS varchar) + '/1/' + CAST(YEAR(@Date) AS varchar) AS datetime)),
  RIGHT('0' + CAST(MONTH(@Date) AS varchar), 2),
  DATENAME(MONTH, @Date),
  DATEPART(QUARTER, @Date),
  CASE DATEPART(QUARTER, @Date)
   WHEN 1 THEN 'First'
   WHEN 2 THEN 'Second'
   WHEN 3 THEN 'Third'
   WHEN 4 THEN 'Fourth'
  END,
  CAST(YEAR(@Date) AS char(4));

 SET @Date = DATEADD(DAY, 1, @Date);
END;

-- Format standard date (MM/DD/YYYY)
UPDATE Dim_Date
SET StandardDate = [Month] + '/' + [Day] + '/' + [Year];

-- ✅ Optional: Add US holidays
-- Example: New Year's Day
UPDATE Dim_Date SET Holiday_name_en = 'New Year''s Day' WHERE Month = '01' AND Day = '01';
UPDATE Dim_Date SET Holiday_name_en = 'Valentine''s Day' WHERE Month = '02' AND Day = '14';
UPDATE Dim_Date SET Holiday_name_en = 'Independence Day' WHERE Month = '07' AND Day = '04';
UPDATE Dim_Date SET Holiday_name_en = 'Halloween' WHERE Month = '10' AND Day = '31';
UPDATE Dim_Date SET Holiday_name_en = 'Christmas Day' WHERE Month = '12' AND Day = '25';

-- Example: Thanksgiving (4th Thursday of November)
UPDATE Dim_Date
SET Holiday_name_en = 'Thanksgiving Day'
WHERE Month = '11' AND DayOfWeek = 'Thursday' AND DOWInMonth = 4;

-- ✅ Add any other local holidays manually if حابب تعمل dimension for مصر أو غيرها.

-- ✅ Optional indexes
CREATE INDEX IDX_Dim_Date_Year ON Dim_Date ([Year]);
CREATE INDEX IDX_Dim_Date_Month ON Dim_Date ([Month]);
CREATE INDEX IDX_Dim_Date_StandardDate ON Dim_Date ([StandardDate]);
CREATE INDEX IDX_Dim_Date_Holiday ON Dim_Date ([Holiday_name_en]);

PRINT 'Done at: ' + CONVERT(varchar, GETDATE(), 113);

------------------------------------------------------------------------
/*
Brief : This script updates the Dim_Date table with official Egyptian holidays 
        in both English and Arabic.
Author: Mohamed Roshdy
Date  : 10-02-2025
*/
-----------------------------------------------------------------
-- add arabic column if not exist
------------------------------------------------------------------
ALTER TABLE dbo.Dim_Date
ADD Holiday_name_ar nvarchar(100) NULL;
GO

--  set all = NULL
UPDATE dbo.Dim_Date
SET Holiday_name_en = NULL,
    Holiday_name_ar = NULL;
GO

-- رأس السنة الميلادية (1 يناير)
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'New Year''s Day',
    Holiday_name_ar = N'رأس السنة الميلادية'
WHERE Month = '01' AND Day = '01';

-- ثورة 25 يناير
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'January 25 Revolution Day and Police Day',
    Holiday_name_ar = N'ثورة 25 يناير ويوم الشرطة'
WHERE Month = '01' AND Day = '25';

-- عيد تحرير سيناء (25 أبريل)
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'Sinai Liberation Day',
    Holiday_name_ar = N'عيد تحرير سيناء'
WHERE Month = '04' AND Day = '25';

-- عيد العمال (1 مايو)
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'Labor Day',
    Holiday_name_ar = N'عيد العمال'
WHERE Month = '05' AND Day = '01';

-- ثورة 30 يونيو
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'June 30 Revolution Day',
    Holiday_name_ar = N'ثورة 30 يونيو'
WHERE Month = '06' AND Day = '30';

-- عيد الفطر
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'Eid al-Fitr',
    Holiday_name_ar = N'عيد الفطر'
WHERE Date IN ('2020-05-24', '2021-05-13', '2022-05-02', '2023-04-21', '2024-04-10');

-- عيد الأضحى
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'Eid al-Adha',
    Holiday_name_ar = N'عيد الأضحى'
WHERE Date IN ('2020-07-31', '2021-07-20', '2022-07-09', '2023-06-28', '2024-06-16');

-- رأس السنة الهجرية
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'Islamic New Year',
    Holiday_name_ar = N'رأس السنة الهجرية'
WHERE Date IN ('2020-08-20', '2021-08-09', '2022-07-30', '2023-07-19', '2024-07-07');

-- عيد القوات المسلحة (6 أكتوبر)
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'Armed Forces Day',
    Holiday_name_ar = N'عيد القوات المسلحة'
WHERE Month = '10' AND Day = '06';

-- عيد النصر (23 ديسمبر)
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'Victory Day',
    Holiday_name_ar = N'عيد النصر'
WHERE Month = '12' AND Day = '23';

-- شم النسيم
UPDATE dbo.Dim_Date
SET Holiday_name_en = 'Sham El Nessim',
    Holiday_name_ar = N'شم النسيم'
WHERE Date IN ('2020-04-20', '2021-05-03', '2022-04-25', '2023-04-17', '2024-05-06');
GO

--     لا توجد مناسبة
UPDATE dbo.Dim_Date 
SET Holiday_name_en = 'No Holiday',
    Holiday_name_ar = N'لا يوجد مناسبة'
WHERE Holiday_name_en IS NULL OR Holiday_name_ar IS NULL;
GO

-----------------------------------------------------------------------------------------------------

SET ANSI_PADDING OFF;
BEGIN TRY
 DROP TABLE [Dim_Time];
END TRY
BEGIN CATCH
 --DO NOTHING
END CATCH;

CREATE TABLE [dbo].[Dim_Time] (
 [Time_SK] int IDENTITY(1,1) NOT NULL,
 [Time] time(0) NOT NULL,
 [Hour] char(2) NOT NULL,
 [MilitaryHour] char(2) NOT NULL,
 [Minute] char(2) NOT NULL,
 [Second] char(2) NOT NULL,
 [AmPm] char(2) NOT NULL,
 [StandardTime] char(11) NULL,
 CONSTRAINT [PK_Dim_Time] PRIMARY KEY CLUSTERED (
  [Time_SK] ASC
 ) WITH (
  PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
  ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
 ) ON [PRIMARY]
) ON [PRIMARY];

GO
SET ANSI_PADDING OFF;

PRINT CONVERT(varchar, GETDATE(), 113); -- Start time

-- Load time data for every second of the day
DECLARE @Time datetime;
SET @Time = '00:00:00';

TRUNCATE TABLE [Dim_Time];

WHILE @Time <= '23:59:59'
BEGIN
 INSERT INTO [dbo].[Dim_Time] ([Time], [Hour], [MilitaryHour], [Minute], [Second], [AmPm])
 SELECT 
  CONVERT(varchar, @Time, 108),
  CASE 
   WHEN DATEPART(HOUR, @Time) = 0 THEN 12
   WHEN DATEPART(HOUR, @Time) > 12 THEN DATEPART(HOUR, @Time) - 12
   ELSE DATEPART(HOUR, @Time)
  END,
  RIGHT('0' + CAST(DATEPART(HOUR, @Time) AS varchar), 2),
  RIGHT('0' + CAST(DATEPART(MINUTE, @Time) AS varchar), 2),
  RIGHT('0' + CAST(DATEPART(SECOND, @Time) AS varchar), 2),
  CASE WHEN DATEPART(HOUR, @Time) >= 12 THEN 'PM' ELSE 'AM' END;

 SET @Time = DATEADD(SECOND, 1, @Time);
END;

-- Fix formatting
UPDATE [Dim_Time] SET [Hour] = '0' + [Hour] WHERE LEN([Hour]) = 1;
UPDATE [Dim_Time] SET [Minute] = '0' + [Minute] WHERE LEN([Minute]) = 1;
UPDATE [Dim_Time] SET [Second] = '0' + [Second] WHERE LEN([Second]) = 1;
UPDATE [Dim_Time] SET [MilitaryHour] = '0' + [MilitaryHour] WHERE LEN([MilitaryHour]) = 1;

UPDATE [Dim_Time]
SET [StandardTime] = 
  CASE WHEN [Hour] = '00' THEN '12' ELSE [Hour] END + ':' + [Minute] + ':' + [Second] + ' ' + [AmPm]
WHERE [StandardTime] IS NULL;

-- Create indexes
CREATE UNIQUE NONCLUSTERED INDEX [IDX_Dim_Time_Time] ON [dbo].[Dim_Time] ([Time]);
CREATE NONCLUSTERED INDEX [IDX_Dim_Time_Hour] ON [dbo].[Dim_Time] ([Hour]);
CREATE NONCLUSTERED INDEX [IDX_Dim_Time_MilitaryHour] ON [dbo].[Dim_Time] ([MilitaryHour]);
CREATE NONCLUSTERED INDEX [IDX_Dim_Time_Minute] ON [dbo].[Dim_Time] ([Minute]);
CREATE NONCLUSTERED INDEX [IDX_Dim_Time_Second] ON [dbo].[Dim_Time] ([Second]);
CREATE NONCLUSTERED INDEX [IDX_Dim_Time_AmPm] ON [dbo].[Dim_Time] ([AmPm]);
CREATE NONCLUSTERED INDEX [IDX_Dim_Time_StandardTime] ON [dbo].[Dim_Time] ([StandardTime]);

PRINT CONVERT(varchar, GETDATE(), 113); -- End time


-----------------------------------------------------------------------------------------------------

create table dim_customer
(
    cus_key_sk int identity(1,1) primary key,
    cus_id_bk int not null,
    f_name varchar(200),
    l_name varchar(200),
    email varchar(350)
)

-----------------------------------------------------------------------------------------------------

create table dim_address
(
    add_key_sk int primary key identity(1,1),
    add_id_bk int not null,
    street_number varchar(10),
    street_name varchar(200),
    city varchar(100),
    country_id_bk int not null,
    country_name varchar(200),
    start_date datetime,
    end_date datetime,
    IsCurrent int
)

-----------------------------------------------------------------------------------------------------

create table dim_bridge_customer_address
(
    cus_key_sk int,
    add_key_sk int,
    address_status varchar(30)

    constraint pk_b_ca primary key (cus_key_sk , add_key_sk),
    constraint fk1_b_ca foreign key (cus_key_sk) references dim_customer(cus_key_sk),
    constraint fk2_b_ca foreign key (add_key_sk) references dim_address(add_key_sk)
)

-----------------------------------------------------------------------------------------------------

create table fact_table_gravity_book_store
(
    fact_table_sk int primary key identity(1,1),

    order_id_dd int not null,
    line_id_dd int not null,

    book_key_sk int not null,
    cus_key_sk int not null,
    method_id_pk int not null,
    history_key_sk int not null,
    time_sk int not null,
    date_sk int not null,

    shipping_cost decimal(6,2),
    book_price decimal(5,2),

    constraint fk1_fact foreign key (book_key_sk) references dim_book(book_key_sk),
    constraint fk2_fact foreign key (cus_key_sk) references dim_customer(cus_key_sk),
    constraint fk3_fact foreign key (method_id_pk) references dim_shipping_method(method_id_pk),
    constraint fk4_fact foreign key (history_key_sk) references dim_order_history(history_key_sk),
    constraint fk5_fact foreign key (date_sk) references Dim_Date(Date_SK),
    constraint fk6_fact foreign key (time_sk) references Dim_Time(Time_SK)



)
-----------------------------------------------------------------------------------------------------


alter table [dbo].[dim_book]
alter column [publicationDate] datetime

select dd.Date_SK , dd.Date
from [dbo].[Dim_Date] as dd

select dt.Time_SK , dt.Time
from [dbo].[Dim_Time] as dt

select oh.history_key_sk , oh.history_id_bk
from [dbo].[dim_order_history] as oh

select c.cus_key_sk , c.cus_id_bk
from [dbo].[dim_customer] as c

select b.book_key_sk , b.book_id_bk
from [dbo].[dim_book] as b


delete from [dbo].[dim_address]
delete from [dbo].[dim_author]
delete from [dbo].[dim_book]
delete from [dbo].[dim_bridge_book_author]
delete from [dbo].[dim_bridge_customer_address]
delete from [dbo].[dim_customer]
delete from [dbo].[Dim_Date]
delete from [dbo].[dim_order_history]
delete from [dbo].[dim_shipping_method]
delete from [dbo].[Dim_Time]
delete from [dbo].[fact_table_gravity_book_store]

select * from [dbo].[dim_address]
select * from [dbo].[dim_author]
select * from [dbo].[dim_book]
select * from [dbo].[dim_bridge_book_author]
select * from [dbo].[dim_bridge_customer_address]
select * from [dbo].[dim_customer]
select * from [dbo].[Dim_Date]
select * from [dbo].[dim_order_history]
select * from [dbo].[dim_shipping_method]
select * from [dbo].[Dim_Time]
select * from [dbo].[fact_table_gravity_book_store]

alter table [dbo].[dim_author]
alter column [author_name] varchar(400)

ALTER TABLE [dbo].[dim_author]
ALTER COLUMN [author_name] NVARCHAR(400);


ALTER TABLE [dbo].[dim_order_history]
ALTER COLUMN [status_value] NVARCHAR(400);

ALTER TABLE [dbo].[dim_book]
ALTER COLUMN [isbn13] NVARCHAR(400);
