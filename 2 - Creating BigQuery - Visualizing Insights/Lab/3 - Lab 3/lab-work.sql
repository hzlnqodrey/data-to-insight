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