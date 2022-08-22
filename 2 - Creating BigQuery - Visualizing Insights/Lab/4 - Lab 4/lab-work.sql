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