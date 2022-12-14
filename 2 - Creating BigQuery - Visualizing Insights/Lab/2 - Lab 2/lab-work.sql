-- Exploring newly loaded data with SQL
-- Next, practice with a basic query to gain insights from the new products table.

-- In the Query editor, write a query to list the top 5 products with the highest stockLevel:

#standardSQL
SELECT
  *
FROM
  ecommerce.products
ORDER BY
  stockLevel DESC
LIMIT  5

-- Ingest a new dataset from a Google Spreadsheet
-- Select Compose New Query.

-- Execute this next query to show which products are in the greatest restocking need based on inventory turnover and how quickly they can be resupplied:

#standardSQL
SELECT
  *,
  SAFE_DIVIDE(orderedQuantity,stockLevel) AS ratio
FROM
  ecommerce.products
WHERE
# include products that have been ordered and
# are 80% through their inventory
orderedQuantity > 0
AND SAFE_DIVIDE(orderedQuantity,stockLevel) >= .8
ORDER BY
  restockingLeadTime DESC

-- Copied!
-- Note: If you specify a relative project name path like ecommerce.products instead of project_id.ecommerce.products, BigQuery will assume the current project.

Query data from an external spreadsheet
Click Compose New Query.

Add the below query then Run:

#standardSQL
SELECT * FROM ecommerce.products_comments WHERE comments IS NOT NULL
Copied!
