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

JSON result from the query above:
[{
  "person": ["sally"],
  "fruit_array": ["raspberry", "blackberry", "strawberry", "cherry"],
  "total_cost": ["10.99"]
}, {
  "person": ["frederick"],
  "fruit_array": ["orange", "apple"],
  "total_cost": ["5.55"]
}]

-- Uploading JSON files
-- What if you had a JSON file that you needed to ingest into BigQuery? You'll try this now.

-- Create a new table in the fruit_store dataset. To create a table, click on the View actions icon next to the fruit_store dataset and select Open. Then click Create table from the right panel.

-- Note: You may have to widen your browser window to see the Create table option.
-- Add the following details for the table:

-- Source: Choose Google Cloud Storage in the Create table from dropdown.
-- Select file from GCS bucket: data-insights-course/labs/optimizing-for-performance/shopping_cart.json
-- File format: JSONL (Newline delimited JSON)
-- Call the new Table name fruit_details. Under Schema, click on the checkbox of Auto detect

-- Click Create table.

-- Click on the table fruit_details.

-- In the schema, note that fruit_array is marked as REPEATED which means it is an array.