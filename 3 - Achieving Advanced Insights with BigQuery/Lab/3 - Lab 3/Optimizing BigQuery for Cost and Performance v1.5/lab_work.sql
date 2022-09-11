Load and query relational data
In this section, you measure query performance for relational data in BigQuery.

BigQuery supports large JOINs, and JOIN performance is good. However, BigQuery is a columnar datastore, and maximum performance is achieved on denormalized datasets. Because BigQuery storage is inexpensive and scalable, it's a good practice to denormalize and pre-JOIN datasets into homogeneous tables. In other words, you exchange compute resources for storage resources (the latter being more performant and cost-effective).

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
Here's a diagram of the relational schema:

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
Note: When you've created a table previously, the Select Previous Job option allows you to quickly use your settings to create similar tables.

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