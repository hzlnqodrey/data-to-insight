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