Load and query relational data
In this section, you measure query performance for relational data in BigQuery.

BigQuery supports large JOINs, and JOIN performance is good. However, BigQuery is a columnar datastore, and maximum performance is achieved on denormalized datasets. Because BigQuery storage is inexpensive and scalable, it is a good practice to denormalize and pre-JOIN datasets into homogeneous tables. In other words, you exchange compute resources for storage resources (the latter being more performant and cost-effective).

In this section, you:

Upload a set of tables from a relational schema (in 3rd normal form).
Run queries against the relational tables.
Note the performance of the queries to compare to the performance of the same queries against a table from a denormalized schema containing the same information.
You upload tables that have a relational schema. The relational schema consists of the following tables:

Table name	Description
sales	Contains the date and sales metrics.
item	The description of the item sold.
vendor	The producer of the item.
category	The grouping to which the item belongs.
store	The store that sold th item.
county	The county where the item was sold.
convenience_store	The list of stores that are considered convenience stores.
Heres a diagram of the relational schema:

1.png

Create the sales table
In the Explorer section, click on the View actions icon next to liquor_sales dataset, select Open and then click Create Table.
2.png

On the Create Table page, in the Source section:

For Create table from, choose Google Cloud Storage.

Enter the path to the Google Cloud Storage bucket name:

data-insights-course/labs/optimizing-for-performance/sales.csv
Copied!
For File format, choose CSV.
Note: When youve created a table previously, the Select Previous Job option allows you to quickly use your settings to create similar tables.

In the Destination section:

For Table name, enter sales.
Leave the remaining destination fields at their defaults.
3.png

In the Schema section:

Click Edit as text.

Copy and paste the below schema.

[
        {
                "name": "date",
                "type": "STRING"
        },
        {
                "name": "store",
                "type": "STRING"
        },
        {
                "name": "category",
                "type": "STRING"
        },
        {
                "name": "vendor_no",
                "type": "STRING"
        },
        {
                "name": "item",
                "type": "STRING"
        },
        {
                "name": "state_btl_cost",
                "type": "FLOAT"
        },
        {
                "name": "btl_price",
                "type": "FLOAT"
        },
        {
                "name": "bottle_qty",
                "type": "INTEGER"
        },
        {
                "name": "total",
                "type": "FLOAT"
        }
]
Copied!
Click Advanced options to display the these options:

For Field delimiter, verify that Comma is selected.
Because sales.csv contains a single header row, set Header rows to skip, to 1.
Check Quoted newlines.
Accept the remaining default values and click Create Table.
4.png

BigQuery creates a load job to create the table and upload data into the table (this may take a few seconds). Click Personal History to track job progress.

Create the remaining tables
Create the remaining tables in the relational schema using Cloud Shell command line.

Create the category table:

bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines liquor_sales.category gs://data-insights-course/labs/optimizing-for-performance/category.csv category:STRING,category_name:STRING
Copied!
Create the convenience_store table:

bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines liquor_sales.convenience_store gs://data-insights-course/labs/optimizing-for-performance/convenience_store.csv store:STRING
Copied!
Create the county table:

bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines liquor_sales.county gs://data-insights-course/labs/optimizing-for-performance/county.csv county_number:STRING,county:STRING
Copied!
Create the item table:

bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines liquor_sales.item gs://data-insights-course/labs/optimizing-for-performance/item.csv item:STRING,description:string,pack:INTEGER,liter_size:INTEGER
Copied!
Create the store table:

bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines liquor_sales.store gs://data-insights-course/labs/optimizing-for-performance/store.csv store:STRING,name:STRING,address:STRING,city:STRING,zipcode:STRING,store_location:STRING,county_number:STRING
Copied!
Create the vendor table:

bq load --source_format=CSV --skip_leading_rows=1 --allow_quoted_newlines liquor_sales.vendor gs://data-insights-course/labs/optimizing-for-performance/vendor.csv vendor_no:STRING,vendor:STRING
Copied!
Go back to the BigQuery web UI. Confirm you see the new tables loaded into your liquor_sales dataset. Refresh the browser if needed.

f82c581950144db1.png

Query relational data
You use the Query editor to query your data.

Under the Query editor code box, click More > Query Settings.

In the Resource management, Cache preference section, uncheck Use Cached Results and click Save. If you have to run the query more than once, you don't want to use cached results.

In the Query editor window, enter the following query against the relational tables and click Run.

#standardSQL
SELECT
  gstore.county AS county,
  ROUND(cstore_total/gstore_total * 100,1) AS cstore_percentage
FROM (
  SELECT
    cy.county AS county,
    SUM(total) AS gstore_total
  FROM
    `liquor_sales.sales` AS s
  JOIN
    `liquor_sales.store` AS st
  ON
    s.store = st.store
  JOIN
    `liquor_sales.county` AS cy
  ON
    st.county_number = cy.county_number
  LEFT OUTER JOIN
    `liquor_sales.convenience_store` AS c
  ON
    s.store = c.store
  WHERE
    c.store IS NULL
  GROUP BY
    county) AS gstore
JOIN (
  SELECT
    cy.county AS county,
    SUM(total) AS cstore_total
  FROM
    `liquor_sales.sales` AS s
  JOIN
    `liquor_sales.store` AS st
  ON
    s.store = st.store
  JOIN
    `liquor_sales.county` AS cy
  ON
    st.county_number = cy.county_number
  LEFT OUTER JOIN
    `liquor_sales.convenience_store` AS c
  ON
    s.store = c.store
  WHERE
    c.store IS NOT NULL
  GROUP BY
    county) AS hstore
ON
  gstore.county = hstore.county
Copied!
At the bottom, in the Query results section, click on the Results tab, note the Query complete time. An example is shown below (your execution time may vary).
Query_results6.png

This will be compared to the time to query a flattened dataset in later sections.

Load and query flattened data
In this section, you denormalize the schemas and analyze liquor sales for the state of Iowa using the flattened data. Running this query on the flattened data should be faster than running on the relational data. You will note the time to compare and confirm.

A denormalized schema flattens all relational data into a single row. For example, in the denormalized schema, county_number, county, store, name, address, city, zipcode, store_location, county_number, and cstore are fields containing all fields from the County, Store, and Convenience_store tables.

Note:

The cstore field (in the denormalized schema) represents the convenience_store.store field in the relational schema above. It has a value of Y if a store is a convenience store, and null otherwise.

The following diagram shows the denormalized schema.

b079709267b700ae.png

Create the "iowa_sales_denorm" table
In the left pane, select liquor_sales dataset and click Create Table on the right.
The Create table dialog opens.

In the Source section:

For Create table from, choose Google Cloud Storage.

Enter the path to the Google Cloud Storage bucket name:

data-insights-course/labs/optimizing-for-performance/iowa_sales_denorm.csv
Copied!
For File format, choose CSV.

In the Destination section:

For Table name, enter iowa_sales_denorm.

Leave the remaining destination fields at their defaults.

In the Schema section:

Click Edit as text.

Copy and paste the below schema.

[
        {
                "name": "date",
                "type": "STRING"
        },
        {
                "name": "cstore",
                "type": "STRING"
        },
        {
                "name": "store",
                "type": "STRING"
        },
        {
                "name": "name",
                "type": "STRING"
        },
        {
                "name": "address",
                "type": "STRING"
        },
        {
                "name": "city",
                "type": "STRING"
        },
        {
                "name": "zipcode",
                "type": "STRING"
        },
        {
                "name": "store_location",
                "type": "STRING"
        },
        {
                "name": "county_number",
                "type": "STRING"
        },
        {
                "name": "county",
                "type": "STRING"
        },
        {
                "name": "category",
                "type": "STRING"
        },
        {
                "name": "category_name",
                "type": "STRING"
        },
        {
                "name": "vendor_no",
                "type": "STRING"
        },
        {
                "name": "vendor",
                "type": "STRING"
        },
        {
                "name": "item",
                "type": "STRING"
        },
        {
                "name": "description",
                "type": "STRING"
        },
        {
                "name": "pack",
                "type": "INTEGER"
        },
        {
                "name": "liter_size",
                "type": "INTEGER"
        },
        {
                "name": "state_btl_cost",
                "type": "FLOAT"
        },
        {
                "name": "btl_price",
                "type": "FLOAT"
        },
        {
                "name": "bottle_qty",
                "type": "INTEGER"
        },
        {
                "name": "total",
                "type": "FLOAT"
        }
]
Copied!
In the Advanced options section:

For Field delimiter, verify that Comma is selected.
Because iowa_sales_denorm.csv contains a single header row, for Header rows to skip, enter 1.
Check Quoted newlines.
Accept the remaining default values and click Create Table.
BigQuery creates a load job to create the table and upload data into the table (this may take a few seconds). Click Personal History to track job progress.

Enter and run the following query against the table with a denormalized schema (this query produces the same results as the query in the previous section):

#standardSQL
SELECT
  gstore.county AS county,
  ROUND(cstore_total/gstore_total * 100,1) AS cstore_percentage
FROM (
  SELECT
    county,
    sum(total) AS gstore_total
  FROM
    `liquor_sales.iowa_sales_denorm`
  WHERE cstore is null
  GROUP BY
    county) AS gstore
JOIN (
  SELECT
    county,
    sum(total) AS cstore_total
  FROM
    `liquor_sales.iowa_sales_denorm`
  WHERE cstore is not null
  GROUP BY
    county) AS cstore
ON gstore.county = cstore.county
ORDER BY county
Copied!
At the bottom, in the Query results section, click on the Results tab, note the Query complete time. This will be compared to the time to query a flattened dataset in later sections.

Note the time the query takes to run by subtracting the Start Time from the End Time.

Notice that the query corresponding to the table with denormalized schema runs slightly faster, and has simpler syntax. Wherever possible, pre-JOIN datasets into homogeneous tables to optimize performance in BigQuery.

Compare query performance with Execution Details
Select PROJECT HISTORY.

Click the first query job you ran against the normalized relational schema, then click OPEN AS NEW QUERY.

Select Execution details.

The execution plan has two major sections:

High level perforomance benchmarks

Elapsed time: total time for the query to process
Slot time consumed: if the query were not processed in parallel on multiple machines, how long would it take to process
Bytes shuffled: Automatic in-memory data shuffling for massive parallel processing
Bytes spilled to disk: If data cannot be processed in memory, how much was spilled to persistent disk (usually data skew is to blame)
Average and max worker timing by type of work per stage

First, compare the benchmark timings between each of the queries we ran.


For the query corresponding to the table with denormalized schema, what do you notice?

All benchmark field values were decreased

The Elapsed time and Slot time consumed decreased

The results were the same

The Bytes shuffled, Slot time consumed, and Bytes spilled to disk increased

Next, compare the type of work where the workers spent the most time.

Query 1: Relational schema Execution details
5ff87d48cc569508.png

126d7673a5a1cefc.png

Query 2: Denormalized schema Execution details
9ce22224aca1ac57.png

20011cf30277499c.png

Observations:

The denormalized query (#2) is faster and uses less slot time to achieve the same result
The relational query (#1) has many more input stages and spends the most worker time in joining the datasets together
The denormalized query (#2) spends the most time reading data input and outputting the results. There is minimal time spent in aggregations and joins.
Neither query resulted in bytes spilled to disk which suggests out datasets are likely not skewed (or significantly large enough to spill out from memory from an individual worker)
Note:

The queries used in this lab are for demonstration purposes only. The time difference between the 2 queries becomes more significant as the dataset sizes increase and the complexity of the JOIN clauses increases. Learn more about the Execution Details and query plan optimization here.

Avoiding Performance Anti-Patterns
Now that you are familiar with effective database schema design, it is time to practice optimizing some poorly written queries.

The below query is running slowly, what can you do to correct it?

Copy and paste the below query into the Query editor and run the query to get a benchmark.

Goal: Count all the U.S. non-profit organizations that have filed taxes using paper (non-electronic) in 2015

#standardSQL
# count all paper filings for 2015
SELECT * FROM `bigquery-public-data.irs_990.irs_990_2015`
WHERE UPPER(elf) LIKE '%P%' #Paper Filers in 2015
ORDER BY ein
# 86,831 as per pagination count, 23s
Copied!
What can you do to improve the performance?

Compare against the below solution

#standardSQL
SELECT COUNT(*) AS paper_filers FROM `bigquery-public-data.irs_990.irs_990_2015`
WHERE elf = 'P' #Paper Filers in 2015
# 86,831 at 2s
/*
Remove ORDER BY when there is no limit
Use Aggregation Functions
Examine data and confirmed P always uppercase
*/
Copied!
Run your updated version and track the time.

Clear the Query editor.

This new below query is running slowly (run the query to get a benchmark - Stop after 30 seconds if it does not complete)

Goal: Using the Employer Identification Number (ein) as a linking field, join together the tax return filings table with the organizational names table and return the names of all the organizations that filed in 2015.

Add this query in the Query editor, then click Run.

#standardSQL
  # get all Organization names who filed in 2015
SELECT
  tax.ein,
  name
FROM
  `bigquery-public-data.irs_990.irs_990_2015` tax
JOIN
  `bigquery-public-data.irs_990.irs_990_ein` org
ON
  tax.tax_pd = org.tax_period
Copied!
Correct the above query (hint: remember the correct JOIN field condition for our schema)

Compare against the below solution:

Add this query in the Query editor, then click Run.

#standardSQL
  # get all Organization names who filed in 2015
SELECT
  tax.ein,
  name
FROM
  `bigquery-public-data.irs_990.irs_990_2015` tax
JOIN
  `bigquery-public-data.irs_990.irs_990_ein` org
ON
  tax.ein = org.ein
  # 86,831 as per pagination count, 23s
/*
   Incorrect JOIN key resulted in CROSS JOIN
   Correct result: 294,374 at 13s
*/
Copied!
Run your updated version and track the time. Do you see an improvement? How quickly does the query run?

Lessons learned:


Before joining, you should ensure the following:

You have the correct linking field and understand the relationship between the data (1-to-many, many-to-one, many-to-many)

That data can only be from a table with a relational schema

Data in the linking field has been sorted and can the relationship can only be 1-to-many

That tables are of similar size and all data is of the same type


What to avoid:

Query datasets with no more than five tables

Querying flattened data

Selecting any tables with STRING data

Selecting more columns than you need

Congratulations!
This concludes this hands-on lab looking at Effective BigQuery Schema Design and Query Performance. You have loaded CVS and JSON files into BigQuery tables, transformed data and join tables, store query results, and then confirm data was transformed and loaded correctly.