-- Creating Date-Partitioned Tables in BigQuery v1.5
-- # Creating tables with date partitions
-- A partitioned table is a table that is divided into segments, called partitions, that make it easier to manage and query your data. By dividing a large table into smaller partitions, you can improve query performance, and control costs by reducing the number of bytes read by a query.

-- Now you will create a new table and bind a date or timestamp column as a partition. Before we do that, let's explore the data in the non-partitioned table first.


-- Query webpage analytics for a sample of visitors in 2017
-- In the Query Editor, add the below query. Before running, note the total amount of data it will process as indicated next to the query validator icon: "This query will process 1.74 GB when run".

#standardSQL
SELECT DISTINCT
  fullVisitorId,
  date,
  city,
  pageTitle
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE date = '20170708'
LIMIT 5
-- Copied!
-- Click RUN.

-- The query returns 5 results.

-- Query webpage analytics for a sample of visitor

-- Query webpage analytics for a sample of visitors in 2018
-- Let's modify the query to look at visitors for 2018 now.

-- In the Query Editor, add the below query:

#standardSQL
SELECT DISTINCT
  fullVisitorId,
  date,
  city,
  pageTitle
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE date = '20180708'
LIMIT 5

-- Copied!
-- The Query results will tell you how much data this query will process.

-- Click RUN.

-- Notice that the query still processes 1.74 GB even though it returns 0 results. Why? The query engine needs to scan all records in the dataset to see if they satisfy the date matching condition in the WHERE clause. It must look at each record to compare the date against the condition of ‘20180708'.

-- Additionally, the LIMIT 5 does not reduce the total amount of data processed, which is a common misconception.

-- Common use-cases for date-partitioned tables
-- Scanning through the entire dataset everytime to compare rows against a WHERE condition is wasteful. This is especially true if you only really care about records for a specific period of time like:

-- All transactions for the last year
-- All visitor interactions within the last 7 days
-- All products sold in the last month
-- Instead of scanning the entire dataset and filtering on a date field like we did in the earlier queries, we will now setup a date-partitioned table. This will allow us to completely ignore scanning records in certain partitions if they are irrelevant to our query.

-- Create a new partitioned table based on date
-- Click COMPOSE NEW QUERY and add the below query, then RUN:

#standardSQL
 CREATE OR REPLACE TABLE ecommerce.partition_by_day
 PARTITION BY date_formatted
 OPTIONS(
   description="a table partitioned by date"
 ) AS
 SELECT DISTINCT
 PARSE_DATE("%Y%m%d", date) AS date_formatted,
 fullvisitorId
 FROM `data-to-insights.ecommerce.all_sessions_raw`

--  In this query, note the new option - PARTITION BY a field. The two options available to partition are DATE and TIMESTAMP. The PARSE_DATE function is used on the date field (stored as a string) to get it into the proper DATE type for partitioning.

-- Click on the ecommerce dataset, then select the new partiton_by_day table:

-- f15327a7d4da4db9.png

-- Click on the Details tab.

-- Confirm that you see:

-- Partitioned by: Day
-- Partitioning on: date_formatted
-- Partition_by_day3.png

-- Note: Partitions within partitioned tables on your Qwiklabs account will auto-expire after 60 days from the value in your date column. Your personal GCP account with billing-enabled will let you have partitioned tables that don't expire. For the purposes of this lab, the remaining queries will be ran against partitioned tables that have already been created.

-- View data processed with a partitioned table
-- Run the below query, and note the total bytes to be processed:

#standardSQL
SELECT *
FROM `data-to-insights.ecommerce.partition_by_day`
WHERE date_formatted = '2016-08-01'
Copied!
This time ~25 KB or 0.025MB is processed, which is a fraction of what you queried.

-- Now run the below query, and note the total bytes to be processed:

#standardSQL
SELECT *
FROM `data-to-insights.ecommerce.partition_by_day`
WHERE date_formatted = '2018-07-08'
Copied!
You should see This query will process 0 B when run.

-- Why is there 0 bytes processed?