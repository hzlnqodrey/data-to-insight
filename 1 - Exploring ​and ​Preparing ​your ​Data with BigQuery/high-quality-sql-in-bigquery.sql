#standardSQL - Revenue
SELECT
    FORMAT("%'d", totrevenue) AS revenue
FROM `project.dataset.table`
ORDER BY revenue DESC 
LIMIT 10 # make sure you limit your query, because otherwise it just waste of many byte amounts of processing

/* # FORMAT() function is String Manipulation Function that make your data visualization stylish */

#standardSQL - Income
SELECT
    (totrevenue - totfuncexpns) AS income
FROM `project.dataset.table` # `bigquery-public-data.irs_990.irs_990_2015`
WHERE income > 0
ORDER BY income DESC
LIMIT 10

#standardSQL /* Add new fields in SELECT clause to return more data. */
SELECT
    totrevenue AS revenue,
    ein, # employer identification number
    operationschools170cd AS is_school,
FROM `bigquery-public-data.irs_990.irs_990_2015`
ORDER BY totrevenue DESC
LIMIT 10


/* # Pitfall : Using SELECT * to return all columns
# AVOID using * (star) to return all columns
# -> Selecting only the columns you need greatly increases query speed and helps with readibility */


#standardSQL /* Filter Rows using the WHERE clause */
SELECT
    totrevenue AS revenue,
    ein, # employer identification number
    operationschools170cd AS is_school,
FROM `bigquery-public-data.irs_990.irs_990_2015`
WHERE operationschools170cd = 'Y'
ORDER BY totrevenue DESC
LIMIT 10
# why didn't we write this as is_school = 'Y'?
# -> because the AS (Alias) is_school is not known by the filter, because SQL programming read the FROM and then the FILTER Section (WHERE, GROUP BY, ORDER BY, LIMIT), but WHERE is the exception, he cannot be placed by ALIAS or AS'

#######################################################################################################

# Aggregation function /* SUM() COUNT() AVG() MAX() ROUND() etc */

#standardSQL
SELECT
    SUM(totrevenue) AS total_2015_revenue,
    AVG(totrevenue) AS avg_revenue,
    COUNT(ein) AS nonprofit,
    COUNT(DISTINCT ein) AS nonprofit_distinct,
    MAX(noemplyeesw3cnt) AS num_employees
FROM `bigquery-public-data.irs_990.irs_990_2015`

#standardSQL - Embed function inside of other function
SELECT
    SUM(totrevenue) AS total_2015_revenue,
    ROUND(AVG(totrevenue), 2) AS avg_revenue, # round float point value into just 2 float number behind point [xxxxx.xx]
    COUNT(ein) AS nonprofit,
    COUNT(DISTINCT ein) AS nonprofit_distinct,
    MAX(noemplyeesw3cnt) AS num_employees
FROM `bigquery-public-data.irs_990.irs_990_2015`

#standardSQL /* Create Aggregation groupings with GROUP BY */
SELECT
    ein, # not aggregated
    COUNT(ein) AS ein_count # aggregated
FROM `bigquery-public-data.irs_990.irs_990_2015`
GROUP BY ein
ORDER BY ein_count DESC

/* Pitfall: FORGETTING to Group Non-Aggregated Fields
# Do not forget to use a GROUP BY if you are using mix of aggregated and non-aggregated fields */

#standardSQL
SELECT
    company,
    SUM(revenue) AS total,
FROM table
GROUP BY company

/* Locate duplicate records with COUNT + GROUPBY */

/* WHERE clause is filtering rows pre-aggregation */
/* HAVING clause is filtering rows post-aggregation, we can USE ALIAS or AS in HAVING clause */

/* Filter Aggregation with HAVING clause */
SELECT
    ein, # not aggregated
    COUNT(ein) AS ein_count # aggregated
FROM `bigquery-public-data.irs_990.irs_990_2015`
GROUP BY ein
HAVING ein_count > 1
ORDER BY ein_count DESC

/* Example solution: INVOKE parse, convert, filter for 2014 tax period */
#standardSQL
SELECT
    ein,
    tax_pd,
    PARSE_DATE('%Y%m', CAST(tax_pd AS STRING)) AS tax_period
FROM `bigquery-public-data.irs_990.irs_990_2015`
WHERE
EXTRACT(YEAR FROM
    PARSE_DATE('%Y%m', CAST(tax_pd AS STRING))
    ) = 2014
LIMIT 10


