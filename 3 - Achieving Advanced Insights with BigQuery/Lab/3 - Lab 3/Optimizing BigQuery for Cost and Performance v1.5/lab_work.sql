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