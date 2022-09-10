-- Both of these tables are exactly the same. There are two key learnings here:

-- An array is simply a list of items in brackets [ ]
-- BigQuery (in Standard SQL mode) displays arrays as flattened. It simply lists the value in the array vertically (note that all of those values still belong to a single row)
-- Try it yourself. Enter the following in the BigQuery Query Editor:

#standardSQL
SELECT
['raspberry', 'blackberry', 'strawberry', 'cherry'] AS fruit_array
-- Copied!
-- Click Run.

-- Now try executing this one:

#standardSQL
SELECT
['raspberry', 'blackberry', 'strawberry', 'cherry', 33] AS fruit_array
-- Copied!
-- You should get an error that looks like the following:

-- Error: Array elements of types {INT64, STRING} do not have a common supertype at [3:1]

-- Arrays can only share one data type (all strings, all numbers). You might ask at this point, can you have an array of arrays? Yes, they can! This will be covered later.

-- Heres the final table to query against:

#standardSQL
SELECT person, fruit_array, total_cost FROM `data-to-insights.advanced.fruit_store`;
-- Copied!
-- Click Run.

-- After viewing the results, click the JSON tab to view the nested structure of the results.