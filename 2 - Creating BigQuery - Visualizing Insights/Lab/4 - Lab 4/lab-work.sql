-- Identify a key field in your ecommerce dataset
-- Examine the products and fields further. You want to become familiar with the products on the website and the fields you could use to potentially join on to other datasets.

-- Examine the Records
-- In this section, you find how many product names and product SKUs are on your website and whether either one of those fields is unique.

-- Find how many product names and product SKUs are on the website. Copy and Paste the below query in the query EDITOR.

#standardSQL
# how many products are on the website?
SELECT DISTINCT
productSKU,
v2ProductName
FROM `data-to-insights.ecommerce.all_sessions_raw`
-- Copied!
-- Click RUN.

-- Look at the pagination results in the web UI for the total number of records returned, which in this case is 2,273 products and SKUs.

-- But...do the results mean that there are 2,273 unique product SKUs?

-- Copy and Paste the below query to list the number of distinct SKUs are listed using DISTINCT.

#standardSQL
# find the count of unique SKUs
SELECT
DISTINCT
productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw`
-- Copied!
-- Click RUN.

-- The number of distinct SKUs are 1,909.

-- Hmmm. you have 1,909 distinct SKUs which is less than the 2,273 number for total number of products on the website. The first results probably contain products with duplicate SKUs.

-- Take an even closer look at the records. Determine which products have more than one SKU and which SKUs have more than one product.

-- Copy and Paste the below query to determine if some product names have more than one SKU. Notice ou use the STRING_AGG() function to aggregate all the product SKUs that are associated with one product name.

#standardSQL
# how can we find the products with more than 1 sku?
SELECT
DISTINCT
COUNT(DISTINCT productSKU) AS SKU_count,
STRING_AGG(DISTINCT productSKU LIMIT 5) AS SKU,
v2ProductName
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE productSKU IS NOT NULL
GROUP BY v2ProductName
HAVING SKU_count > 1
ORDER BY SKU_count DESC
# product name is not unique (expected for variants)
-- Copied!
-- Click RUN.

-- Results:

-- ece26df3cedfb50b.png

-- Do some product names have more than one SKU? Look at the query results to confirm.

-- Answer: Yes

-- It may also be true that one product name be associated with more than one SKU. This can happen due to variation. For example, one product name (e.g. T-Shirt) can have multiple product variants like color, size, etc. You would expect one product to have many SKUs.

-- Copy and Paste the below query to find out.

#standardSQL
SELECT
DISTINCT
COUNT(DISTINCT v2ProductName) AS product_count,
STRING_AGG(DISTINCT v2ProductName LIMIT 5) AS product_name,
productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE v2ProductName IS NOT NULL
GROUP BY productSKU
HAVING product_count > 1
ORDER BY product_count DESC
# SKU is not unique (indicates data quality issues)
-- Copied!
-- Click RUN.

-- 7b43cfd3d3894578.png

-- Question: When you look at the query results, are there single SKU values with more than one product name associated? What do you notice about those product names?

-- Answer: Yes, it looks like there are quite a few SKUs that have more than one product name. Several of the product names appear to be closely related with a few misspellings (e.g. Waterproof Gear Bag vs Waterproof Gear Bag).

-- You see why this could be an issue in the next section.

-- Pitfall: non-unique key
-- A SKU is designed to uniquely identify one product and will be the basis of your join condition when you join against other tables. Having a non-unique key can cause serious data issues.

-- Write a query to identify all the product names for the SKU 'GGOEGPJC019099'.

-- Possible Solution:

#standardSQL
# multiple records for this SKU
SELECT DISTINCT
v2ProductName,
productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE productSKU = 'GGOEGPJC019099'
-- Copied!
-- Click RUN.

-- v2ProductName	productSKU
-- 7" Dog Frisbee	GGOEGPJC019099
-- 7" Dog Frisbee	GGOEGPJC019099
-- Google 7-inch Dog Flying Disc Blue	GGOEGPJC019099
-- From the query results, it looks like there are three different names for the same product. In this example, there is a special character in one name and a slightly different name for another:

-- Joining website data against your product inventory list
-- See the impact of joining on a dataset with multiple products for a single SKU. First, explore the product inventory dataset (the products table) to see if this SKU is unique there.

-- Copy and Paste the below query.

#standardSQL
# join in another table
# products (has inventory)
SELECT * FROM `data-to-insights.ecommerce.products`
WHERE SKU = 'GGOEGPJC019099'
-- Copied!
-- Click RUN.

-- Join pitfall: Unintentional many-to-one SKU relationship
-- Next, join the inventory dataset against your website product names and SKUs so you can have the inventory stock level associated with each product for sale on the website.

-- Copy and Paste the below query.

#standardSQL
SELECT DISTINCT
website.v2ProductName,
website.productSKU,
inventory.stockLevel
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE productSKU = 'GGOEGPJC019099'
-- Copied!
-- Click RUN.

-- What happens when you join the website table and the product inventory table on SKU? Do you now have inventory stock levels for the product?

-- Answer: Yes but the stockLevel is showing three times (one for each record)!

-- Next, run a query that shows the total stock level for each item in inventory.

-- Copy and Paste the below query.

#standardSQL
SELECT
  productSKU,
  SUM(stockLevel) AS total_inventory
FROM (
  SELECT DISTINCT
  website.v2ProductName,
  website.productSKU,
  inventory.stockLevel
  FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
  JOIN `data-to-insights.ecommerce.products` AS inventory
  ON website.productSKU = inventory.SKU
  WHERE productSKU = 'GGOEGPJC019099'
)
GROUP BY productSKU
-- Copied!
-- Click RUN.

-- Join pitfall solution: use distinct SKUs before joining
-- What are the options to solve your triple counting dilemma? First, you need to only select distinct SKUs from the website before joining on other datasets.

-- Write a query to return the count of distinct productSKU from data-to-insights.ecommerce.all_sessions_raw.

-- Possible Solution:

#standardSQL
SELECT
COUNT(DISTINCT website.productSKU) AS distinct_sku_count
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
Copied!
Answer: 1,909 distinct SKUs from the website dataset

-- Join pitfall: Losing data records after a join
-- Now youre ready to join against your product inventory dataset again.

-- Copy and Paste the below query.

#standardSQL
SELECT DISTINCT
website.productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
-- Copied!
-- Click RUN. How many records were returned? All 1,909 distinct SKUs?

-- Answer: No, just 1,090 records

-- You lost 819 SKUs after joining the datasets, investigate by adding more specificity in your fields.

-- Copy and Paste the below query.

#standardSQL
# pull ID fields from both tables
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
# IDs are present in both tables, how can we dig deeper?
-- Copied!
-- Click RUN.

-- It appears the SKUs are present in both of those datasets after the join.

-- Join pitfall solution: Selecting the correct join type and filtering for NULL
-- The default JOIN type is an INNER JOIN which returns records only if there is a match on both the left and the right tables that are joined.

-- Rewrite the previous query to use a different join type to include all records from the website table, regardless of whether there is a match on a product inventory SKU record. Join type options: INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN, CROSS JOIN

-- Possible Solution:

#standardSQL
# the secret is in the JOIN type
# pull ID fields from both tables
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
LEFT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
-- Copied!
-- Click RUN.

-- You have successfully used a LEFT JOIN to return all of the original 1,909 website SKUs in your results.


-- What do you notice about some of SKUs in the inventory SKU column?

-- Many inventory SKU values are NULL

-- Many inventory SKU values are Not NULL

-- Many inventory Sku values are missing

-- How many SKUs are missing from your product inventory set?

-- Write a query to filter on NULL values from the inventory table.

-- Possible Solution:

#standardSQL
# find product SKUs in website table but not in product inventory table
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
LEFT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE inventory.SKU IS NULL
-- Copied!
-- Click RUN.


-- How many products are missing from your product inventory dataset?

-- 819

-- 700

-- 0

-- Copy and Paste the below query to confirm using one of the specific SKUs from the website dataset.

#standardSQL
# you can even pick one and confirm
SELECT * FROM `data-to-insights.ecommerce.products`
WHERE SKU = 'GGOEGATJ060517'
# query returns zero results
-- Copied!
-- Click RUN.

-- Why might the product inventory dataset be missing SKUs?

-- Answer: Unfortunately, there is no easy answer. It is most likely a business-related question:

-- Some SKUs could be digital products that you don't store in inventory
-- Old products you sold in past website orders are no longer offered in current inventory
-- Legitimate missing data from inventory and should be tracked
-- Are there any products are in the product inventory dataset but missing from the website?

-- Write a query using a different join type to investigate.

-- Possible Solution:

#standardSQL
# reverse the join
# find records in website but not in inventory
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
RIGHT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE website.productSKU IS NULL
-- Copied!
-- Click RUN.

-- Answer: Yes. There are two product SKUs missing from the website dataset

-- Next, add more fields from the product inventory dataset for more details.

-- Copy and Paste the below query.

#standardSQL
# what are these products?
# add more fields in the SELECT STATEMENT
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.*
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
RIGHT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE website.productSKU IS NULL
-- Copied!
-- Click RUN.

-- Why would the below products be missing from the ecommerce website dataset?

-- query_result.png

-- Possible answers:

-- One new product (no orders, no sentimentScore) and one product that is "in store only"
-- Another is a new product with 0 orders
-- Why would the new product not show up on your website dataset?

-- The website dataset is past order transactions by customers brand new products which have never been sold won't show up in web analytics until they're viewed or purchased
-- You typically will not see RIGHT JOINs in production queries. You would simply just do a LEFT JOIN and switch the ordering of the tables.
-- What if you wanted one query that listed all products missing from either the website or inventory?

-- Write a query using a different join type.

-- Possible Solution:

#standardSQL
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
FULL JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE website.productSKU IS NULL OR inventory.SKU IS NULL
-- Copied!
-- Click RUN.

-- You have your 819 + 2 = 821 product SKUs

-- LEFT JOIN + RIGHT JOIN = FULL JOIN which returns all records from both tables regardless of matching join keys. You then filter out where you have mismatches on either side

Join pitfall: Unintentional Cross Join
Not knowing the relationship between data table keys (1:1, 1:N, N:N) can return unexpected results and also significantly reduce query performance.

The last join type is the CROSS JOIN.

Create a new table with a site-wide discount percent that you want to apply across products in the Clearance category.

Replacing the table named qwiklabs-***.

Copy and Paste the below query.

#standardSQL
CREATE OR REPLACE TABLE ecommerce.site_wide_promotion AS
SELECT .05 AS discount;
Copied!
Click RUN.

In the left pane, site_wide_promotion is now listed in the Resource section under qwiklabs-gcp-xxx > ecommerce.

Copy and Paste the below query to find out how many products are in clearance.

SELECT DISTINCT
productSKU,
v2ProductCategory,
discount
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
CROSS JOIN ecommerce.site_wide_promotion
WHERE v2ProductCategory LIKE '%Clearance%'
Copied!
Click RUN.


How many products are in clearance?

82

164

Note: In the syntax there is no join condition (e.g. ON or USING) for a CROSS JOIN. The field is simply multiplied against the first dataset or .05 discount across all items.
Lets see the impact of unintentionally adding more than one record in the discount table.

Copy and Paste the below query to insert two more records into the promotion table.

#standardSQL
INSERT INTO ecommerce.site_wide_promotion (discount)
VALUES (.04),
       (.03);
Copied!
Click RUN.

Next let's view the data values in the promotion table.

Copy and Paste the below query.

#standardSQL
SELECT discount FROM ecommerce.site_wide_promotion
Copied!
Click RUN.


How many records were returned?

10

5

What happens when you apply the discount again across all 82 clearance products?

Copy and Paste the below query.

#standardSQL
# now what happens:
SELECT DISTINCT
productSKU,
v2ProductCategory,
discount
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
CROSS JOIN ecommerce.site_wide_promotion
WHERE v2ProductCategory LIKE '%Clearance%'
Copied!
Click RUN.

How many products are returned?

Answer: Instead of 82, you now have 246 returned which is more records than your original table started with.

Lets investigate the underlying cause by examining one product SKU.

Copy and Paste the below query.

#standardSQL
SELECT DISTINCT
productSKU,
v2ProductCategory,
discount
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
CROSS JOIN ecommerce.site_wide_promotion
WHERE v2ProductCategory LIKE '%Clearance%'
AND productSKU = 'GGOEGOLC013299'
Copied!
Click RUN.

What was the impact of the CROSS JOIN?

Answer:

Since there are 3 discount codes to cross join on, you are multiplying the original dataset by 3

Note: This behavior isn't limited to cross joins, with a normal join you can unintentionally cross join when the data relationships are many-to-many this can easily result in returning millions or even billions of records unintentionally.
The solution is to know your data relationships before you join and dont assume keys are unique.

Deduplicating Rows
At the start of the lab you wrote a query that showed multiple product names for a single SKU. Deduplicating records like this is a common skill for data analysts. Examine one way you can select only one product per SKU.

First, start with the query to show all product names per SKU.

Copy and Paste the below query.

#standardSQL
# recall the earlier query that showed multiple product_names for each SKU
SELECT
DISTINCT
COUNT(DISTINCT v2ProductName) AS product_count,
STRING_AGG(DISTINCT v2ProductName LIMIT 5) AS product_name,
productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE v2ProductName IS NOT NULL
GROUP BY productSKU
HAVING product_count > 1
ORDER BY product_count DESC
Copied!
Click RUN.

Since most of the product names are extremely similar (and you want to map a single SKU to a single product), write a query to only choose one of the product_names. You will be using this StackOverflow post by Felipe Hoffa as inspiration.

Copy and Paste the below query.

#standardSQL
# take the one name associated with a SKU
WITH product_query AS (
  SELECT
  DISTINCT
  v2ProductName,
  productSKU
  FROM `data-to-insights.ecommerce.all_sessions_raw`
  WHERE v2ProductName IS NOT NULL
)
SELECT k.* FROM (
  # aggregate the products into an array and
  # only take 1 result
  SELECT ARRAY_AGG(x LIMIT 1)[OFFSET(0)] k
  FROM product_query x
  GROUP BY productSKU # this is the field you want deduplicated
);
Copied!
Click RUN.

You have successfully deduplicated the product names for each SKU. Experiment with the above query and your own datasets to deduplicate your fields before joining against other datasets.

Test your understanding

An effective way to analyze datasets is:

Eyeball the data, something will pop out at you

Identify a key field to base queries off of

Sort the datasets by size, and then delete the biggest and smallest dataset, combine the rest

Click all that apply: What are the pitfalls of joining data?

Unintentional cross join

Permanently deleting the dataset

Counting some data more than once

Missing data that should have been included


A FULL JOIN returns what?

All records from both tables

Records that are not in both tables

Records only in both tables

Records from one table minus records in both tables

