Exploring newly loaded data with SQL
Next, practice with a basic query to gain insights from the new products table.

In the Query editor, write a query to list the top 5 products with the highest stockLevel:

#standardSQL
SELECT
  *
FROM
  ecommerce.products
ORDER BY
  stockLevel DESC
LIMIT  5