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

-- Create Table Schema:

[
    {
        "name": "race",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "participants",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
            {
                "name": "name",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "splits",
                "type": "FLOAT",
                "mode": "REPEATED"
            }
        ]
    }
]

-- Table Contents

[{
  "race": "800M",
  "participants": [{
    "name": "Rudisha",
    "splits": ["23.4", "26.3", "26.4", "26.1"]
  }, {
    "name": "Makhloufi",
    "splits": ["24.5", "25.4", "26.6", "26.1"]
  }, {
    "name": "Murphy",
    "splits": ["23.9", "26.0", "27.0", "26.0"]
  }, {
    "name": "Bosse",
    "splits": ["23.6", "26.2", "26.5", "27.1"]
  }, {
    "name": "Rotich",
    "splits": ["24.7", "25.6", "26.9", "26.4"]
  }, {
    "name": "Lewandowski",
    "splits": ["25.0", "25.7", "26.3", "27.2"]
  }, {
    "name": "Kipketer",
    "splits": ["23.2", "26.1", "27.3", "29.4"]
  }, {
    "name": "Berian",
    "splits": ["23.7", "26.1", "27.0", "29.3"]
  }]
}]

-- Lab Question: STRUCT()
-- Answer the below questions using the racing.race_results table you created previously.

-- Task: Write a query to COUNT how many racers were there in total.

-- To start, use the below partially written query:

#standardSQL
SELECT COUNT(participants.name) AS racer_count
FROM racing.race_results
-- Copied!
-- Hint: Remember you will need to cross join in your struct name as an additional data source after the FROM.

Possible Solution:

#standardSQL
SELECT COUNT(p.name) AS racer_count
FROM racing.race_results AS r, UNNEST(r.participants) AS p
Copied!
Row	racer_count
1	8
Answer: There were 8 racers who ran the race.

Unpacking ARRAYs with UNNEST( )
Now that you are familiar working with STRUCTs, it's time to apply that same knowledge of unpacking ARRAYs to some traditional arrays.

Recall that the UNNEST operator takes an ARRAY and returns a table, with one row for each element in the ARRAY. This will allow you to perform normal SQL operations like:

Aggregating values within an ARRAY
Filtering arrays for particular values
Ordering and sorting arrays
As a reminder, an Array is an ordered list of elements that share a data type. Here is a string array of the 8 racer names.

['Rudisha','Makhloufi','Murphy','Bosse','Rotich','Lewandowski','Kipketer','Berian']
Copied!
You can create arrays in BigQuery by adding brackets [ ] and comma separating values.

Try the below query and be sure to note how many rows are outputted. Will it be 8 rows?

#standardSQL
SELECT
['Rudisha','Makhloufi','Murphy','Bosse','Rotich','Lewandowski','Kipketer','Berian'] AS normal_array
Copied!
It is a single row with 8 array elements:

Row	normal_array
1	Rudisha
Makhloufi
Murphy
Bosse
Rotich
Lewandowski
Kipketer
Berian
Tip: If you already have a field that isn't in an array format you can aggregate those values into an array by using ARRAY_AGG()

In order to find the racers whose names begin with the letter M, you need to unpack the above array into individual rows so you can use a WHERE clause.

Unpacking the array is done by wrapping the array (or the name of the array) with UNNEST() as shown below. Run the below query and note how many rows are returned.

#standardSQL
SELECT * FROM
UNNEST(['Rudisha','Makhloufi','Murphy','Bosse','Rotich','Lewandowski','Kipketer','Berian']) AS unnested_array_of_names
Copied!
And you should see:

Row	unnested_array_of_names
1	Rudisha
2	Makhloufi
3	Murphy
4	Bosse
5	Rotich
6	Lewandowski
7	Kipketer
8	Berian
You have successfully unnested the array. This is also called flattening the array.

Now add a normal WHERE clause to filter these rows, and run the query:

#standardSQL
SELECT * FROM
UNNEST(['Rudisha','Makhloufi','Murphy','Bosse','Rotich','Lewandowski','Kipketer','Berian']) AS unnested_array_of_names
WHERE unnested_array_of_names LIKE 'M%'
Copied!
Row	unnested_array_of_names
1	Makhloufi
2	Murphy

-- ################################################################

Lab Question: Unpacking ARRAYs with UNNEST( )
Write a query that will list the total race time for racers whose names begin with R. Order the results with the fastest total time first. Use the UNNEST() operator and start with the partially written query below.

Complete the query:

#standardSQL
SELECT
  p.name,
  SUM(split_times) as total_race_time
FROM racing.race_results AS r
, r.participants AS p
, p.splits AS split_times
WHERE
GROUP BY
ORDER BY
;
Copied!
Hint:

You will need to unpack both the struct and the array within the struct as data sources after your FROM clause
Be sure to use aliases where appropriate
Possible Solution:
#standardSQL
SELECT
  p.name,
  SUM(split_times) as total_race_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_times
WHERE p.name LIKE 'R%'
GROUP BY p.name
ORDER BY total_race_time ASC;
Copied!
Row	name	total_race_time
1	Rudisha	102.19999999999999
2	Rotich	103.6

-- #######################################

Filtering within ARRAY values
You happened to see that the fastest lap time recorded for the 800 M race was 23.2 seconds, but you did not see which runner ran that particular lap. Create a query that returns that result.

Complete the partially written query:

#standardSQL
SELECT
  p.name,
  split_time
FROM racing.race_results AS r
, r.participants AS p
, p.splits AS split_time
WHERE split_time = ;
Copied!
Possible Solution:

#standardSQL
SELECT
  p.name,
  split_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_time
WHERE split_time = 23.2;
Copied!
Row	name	split_time
1	Kipketer	23.2