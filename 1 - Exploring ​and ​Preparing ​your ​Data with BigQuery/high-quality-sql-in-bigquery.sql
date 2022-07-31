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


#######################################################################################################
/* Data type conversion function - CAST() : integer to string, string to integer 
    
    Comparing BigQuery data types:

        1. Numeric Data
            a. Integer (int64)
            b. Float (float64)
        2. String Data
            a. Strings (using single quotes '')
        3. Dates
            a. Dates (datetime)
                -> store in universal time format. Allowable range: 0001-01-01 00:00:00 to 9999-12-31 23:59:59.999999
        4. Other
            a. Bollean (Y/N)
            b. Array [`apple`, `bear`]
            c. Struct <apple string>
*/

# Using CAST to convert between data types
- SELECT CAST("12345" AS INT64)
    -> 12345
- SELECT CAST("2018-09-24" AS DATE)
    -> 2018-09-24 (literal DATE format)
- SELECT CAST(1122334455 AS STRING)
    -> "1122334455"
- SELECT SAFE_CAST("apple" AS INT64)
    -> NULL  

/*  what is NULL value?
    -> It is absence of data or an empty set
    -> NULLs are valid values
    -> NULL is ot the same as "" or a valid blank string value
*/

# Handle NULL values with extreme CARE
#standardSQL
SELECT
    ein,
    street,
    city,
    state,
    zip
FROM 
    `bigquery-public-data.irs_990.irs_990_2015`
WHERE
    state IS NULL /* NULL values cannot be equated to and thus have a special IS NULL and IS NOT NULL test */
LIMIT 10;



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

#######################################################################################################

/* Date function - PARSE_DATETIME() */

/* YYYY-MM-DDis the expected format for dates */

/* 

+-----------------------------------------------------------------------------------------------------------------------+
| Date Function                                         | Result                                                        |
+-----------------------------------------------------------------------------------------------------------------------+
| CURRENT_DATE([time_zone])                             | Today's Date                                                  |
| EXTRACT(year FROM your_date_field)                    | Year of Date (try changing to Month, Date, Week, etc.)        |
| DATE_ADD(DATE "2008-12-25", INTERVAL 5 DAY)           | Adds an interval of time                                      |
| SELECT DATE_SUB(DATE "2008-12-25", INTERVAL 5 DAY)    | Substract an interval of time                                 |
| DATE_DIFF(DATE "2010-07-07", DATE "2008-12-25", DAY)  | Substract two dates and RETURN the interval                   |
| DATE_TRUNC(DATE '2008-12-25', MONTH)                  | Truncates the date (e.g 2008-12-01)                           |
| FORMAT_DATETIME()                                     | Formats an existing date to a different date string format    |
| PARSE_DATETIME() #parsing                             | Example: Turn "12/01/2017" to a proper date "2017-12-01"      |
+-----------------------------------------------------------------------------------------------------------------------+


*/

