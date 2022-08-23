-- Data to Insights: Unioning and Joining Datasets v1.1

Practice Unioning and Joining Datasets
Open BigQuery Console
In the Google Cloud Console, select Navigation menu > BigQuery.
The Welcome to BigQuery in the Cloud Console message box opens. This message box provides a link to the quickstart guide and lists UI updates.

Click Done.
Step 1
Compose the query in BigQuery EDITOR.

Ensure #standardSQL is set as your first line of code.

Step 2
Write a Query that will count the number of tax filings by calendar year for all IRS Form 990 filings.

Use the below partially-written query as a guide.

Hint: You will need to use Table Wildcards * with _TABLE_SUFFIX.

#standardSQL
# UNION Wildcard and returning a table suffix
SELECT
  COUNT(*) as number_of_filings,
  AS year_filed
FROM `bigquery-public-data.irs_990.irs_990`
GROUP BY year_filed
ORDER BY year_filed DESC
Copied!
Step 3
Compare with the below solution.

#standardSQL
# UNION Wildcard and returning a table suffix
SELECT
  COUNT(*) as number_of_filings,
  _TABLE_SUFFIX AS year_filed
FROM `bigquery-public-data.irs_990.irs_990_*`
GROUP BY year_filed
ORDER BY year_filed DESC
Copied!
Step 4
Run the query and confirm against the results below.

Result:

wildcard_result_2.png

Step 5
Modify the query you just wrote to only include the IRS tables with the following format: irs_990_YYYY (i.e. filter out pf, ez, ein).

Start with the partially completed query below:

#standardSQL
# UNION Wildcard and returning a table suffix
SELECT
  COUNT(*) as number_of_filings,
  CONCAT(,_TABLE_SUFFIX) AS year_filed
FROM `bigquery-public-data.irs_990.irs_990_*`
GROUP BY year_filed
ORDER BY year_filed DESC
Copied!
Step 6
Compare with the below solution:

#standardSQL
# UNION Wildcard and returning a table suffix
SELECT
  COUNT(*) as number_of_filings,
  CONCAT("2",_TABLE_SUFFIX) AS year_filed
FROM `bigquery-public-data.irs_990.irs_990_2*`
GROUP BY year_filed
ORDER BY year_filed DESC
Copied!
Step 7
Run the query and confirm the result:

result_including_irs_tables_2.png

Step 8
Lastly, modify your query to only include tax filings from tables on or after 2013. Also include average totrevenue and average totfuncexpns as additional metrics.

Hint: Consider using _TABLE_SUFFIX in a filter.

Step 9
Compare with the below solution:

#standardSQL
# count of filings, revenue, expenses since 2013
SELECT
  CONCAT("20",_TABLE_SUFFIX) AS year_filed,
  COUNT(ein) AS nonprofit_count,
  AVG(totrevenue) AS avg_revenue,
  AVG(totfuncexpns) AS avg_expenses
FROM `bigquery-public-data.irs_990.irs_990_20*`
WHERE _TABLE_SUFFIX >= '13'
GROUP BY year_filed
ORDER BY year_filed DESC
Copied!
Step 10
Run the query and confirm the result:

output_including_tax_filings_2.png

Practice Joining Tables
Find the Org Names of all EINs for 2015 with some revenue or expenses. You will need to join tax filing table data with the organization details table.

Step 1
Start with the below query and fill in the tables, join condition, and any filter you will need.

#standard SQL
  # Find the Org Names of all EINs for 2015 with some revenue or expenses, limit 100
SELECT
  tax.ein AS tax_ein,
  org.ein AS org_ein,
  org.name,
  tax.totrevenue,
  tax.totfuncexpns
FROM
  AS tax
JOIN
  AS org
ON
  tax.ein =
WHERE
  > 0
LIMIT
  100;
Copied!
Step 2
Compare your query to the below solution:

#standardSQL
  # Find the Org Names of all EINs for 2015 with some revenue or expenses, limit 100
SELECT
  tax.ein AS tax_ein,
  org.ein AS org_ein,
  org.name,
  tax.totrevenue,
  tax.totfuncexpns
FROM
  `bigquery-public-data.irs_990.irs_990_2015` AS tax
JOIN
  `bigquery-public-data.irs_990.irs_990_ein` AS org
ON
  tax.ein = org.ein
WHERE
  tax.totrevenue + tax.totfuncexpns > 0
LIMIT
  100;
Copied!
Step 3
Run the Query.

Step 4
Confirm the results show 100 records, the names of the Organization, and at least some expenses or revenues.

Step 5
Clear the BigQuery EDITOR.

Practicing Working with NULLs
Step 1
Write a query to find where tax records exist for 2015 but no corresponding Org Name.

Fill out the partially written starter query below:

#standardSQL
  # Find where tax records exist for 2015 but no corresponding Org Name
SELECT
  tax.ein AS tax_ein,
  org.ein AS org_ein,
  org.name,
  tax.totrevenue,
  tax.totfuncexpns
FROM
  `bigquery-public-data.irs_990.irs_990_2015` tax
FULL # Complete the JOIN
  `bigquery-public-data.irs_990.irs_990_ein` org
ON
WHERE
  IS NULL # put tax.ein or org.ein to check here (one is correct)
Copied!
Step 2
Compare your solution to the below:

#standardSQL
  # Find where tax records exist for 2015 but no corresponding Org Name
SELECT
  tax.ein AS tax_ein,
  org.ein AS org_ein,
  org.name,
  tax.totrevenue,
  tax.totfuncexpns
FROM
  `bigquery-public-data.irs_990.irs_990_2015` tax
FULL JOIN
  `bigquery-public-data.irs_990.irs_990_ein` org
ON
  tax.ein = org.ein
WHERE
  org.ein IS NULL
Copied!
Step 3
Run the Query.

Step 4
How many tax filings occurred in 2015 but have no corresponding record in the Organization Details table?

Answer: 14,123 (your answer may be higher as new EIN numbers get added to the public base table)

Congratulations!
You have completed the UNIONING and JOINING Datasets lab.

Learning Review
Use Union Wildcards to treat multiple tables as a single group
Use _TABLE_SUFFIX to filter wildcard tables and create calculated fields with the table name
FULL JOINs (also called FULL OUTER JOINs) include all records from each joined table regardless of whether there are matches on the join key
Having non-unique join keys can result in an unintentional CROSS JOIN (more output rows than input rows) which should be avoided
Use COUNT() and GROUP BY to determine if a key field is indeed unique
End your lab