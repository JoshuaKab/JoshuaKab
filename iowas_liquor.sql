SELECT
  *
FROM
  `bigquery-public-data.iowa_liquor_sales.sales`

---find the duplicate in the dataset

SELECT 
  invoice_and_item_number,
  city, 
  store_number, 
  item_number,
  store_name
FROM `bigquery-public-data.iowa_liquor_sales.sales`
GROUP BY
  invoice_and_item_number,
  city, 
  store_number, 
  item_number,
  store_name
  HAVING COUNT(*) > 1

  --good news there's no duplicate data
--- count the duplicate

SELECT 
  invoice_and_item_number,
  city, 
  store_number, 
  item_number,
  store_name,
  count(*) as num_dpl
FROM `bigquery-public-data.iowa_liquor_sales.sales`
GROUP BY
  invoice_and_item_number,
  city, 
  store_number, 
  item_number,
  store_name
  HAVING COUNT(*) > 1

--- count null in city column 82713

SELECT COUNT(*) as  total_empty_columns
FROM `bigquery-public-data.iowa_liquor_sales.sales`
WHERE city IS NULL



-- HOW MANY PRODUCTS ARE BEING SOLD, ALSO THE NUMBER OF VENDORS ACCROSS DEFFERENT CITIES? 

/* The are 103 different products sales by 587 vendors accross 481 cities */

SELECT
  COUNT(DISTINCT category_name) as product,
  COUNT (DISTINCT vendor_name) as vendor,
  COUNT(distinct city) as cities
FROM  `bigquery-public-data.iowa_liquor_sales.sales`
WHERE city IS NOT NULL

-- HOW MANY STORE ACCROSS THE CITY?
--- number of unique store 3165
SELECT 
COUNT(DISTINCT store_name) as store
FROM`bigquery-public-data.iowa_liquor_sales.sales`
WHERE store_name IS NOT NULL

/* --HOW MANY NAMES OF UNIQUE STORES PER CITY?
--- number of unique store per city
THE City with more unique store name is CEDAR RAPIDS with 165 follow by DES MOINES city with 154  */


SELECT city,
COUNT(DISTINCT store_name) as store
FROM`bigquery-public-data.iowa_liquor_sales.sales`
where city IS NOT NULL
group by city
order by store desc


--- number of unique catergory 103
SELECT
COUNT(DISTINCT category_name) as product
FROM`bigquery-public-data.iowa_liquor_sales.sales`

/* 50,68% of the city are consumneing alchool from the company */
---- 10 top city with high sale from 2023

/*  WHAT'S THE TOTAL SALES, 
    AVERAGE SALES
    MAXIMUM SALES AND 
    MININUM SALE SALES AMOUNT  OF THE COMPANY*/

SELECT
      ROUND(SUM(CAST(sale_dollars AS INT64)),2) AS Total_sales_amount,
      ROUND(AVG(CAST(sale_dollars AS INT64)),2) as avg_sales_amount,
      ROUND(MAX(CAST(sale_dollars AS INT64)),2) as Max_Sale_amount,
      ROUND(MIN(CAST(sale_dollars AS INT64)),2) as Min_Sale_amoun
FROM `bigquery-public-data.iowa_liquor_sales.sales`



---- WHAT TOTAL AMOUNT SALE PER CITY?
--- Profitable city with hihg sales is DES MOINES With 476M total sales

SELECT
 city,
      ROUND(SUM(CAST(sale_dollars AS INT64)),2) AS Total_sales_amount,
      ROUND(AVG(CAST(sale_dollars AS INT64)),2) as avg_sales_amount,
      ROUND(MAX(CAST(sale_dollars AS INT64)),2) as Max_Sale_amount,
      ROUND(MIN(CAST(sale_dollars AS INT64)),2) as Min_Sale_amoun
FROM `bigquery-public-data.iowa_liquor_sales.sales`
GROUP BY city
ORDER BY Total_sales_amount DESC

---- WHAT TOTAL AMOUNT SALE PER PRODUCT?
--- Profitable Product with high sales is TITOS HANDMADE VODKA of 149M total sales With Maxinum sales of 250k

WITH cte as (SELECT
 item_description,
      ROUND(SUM(CAST(sale_dollars AS INT64)),2) AS Total_sales_amount,
      ROUND(AVG(CAST(sale_dollars AS INT64)),2) as Avg_sales_amount,
      ROUND(MAX(CAST(sale_dollars AS INT64)),2) as Max_Sale_amount,
      ROUND(MIN(CAST(sale_dollars AS INT64)),2) as Min_Sale_amoun
FROM `bigquery-public-data.iowa_liquor_sales.sales`
GROUP BY item_description
ORDER BY Total_sales_amount DESC)

SELECT *
FROM cte


------- WHAT VANDOR HAS THE HIGHEST SALES AMOUNT? 
--- DIAGEO AMERICAS  WITH 820M SALES AMOUNT


WITH sum_per_store AS
  (SELECT vendor_name, 
  ROUND(SUM(Sale_dollars),2) AS Total_sales_amount,
   FROM `bigquery-public-data.iowa_liquor_sales.sales`
   WHERE sale_dollars <> 0
   GROUP BY vendor_name)
SELECT *
FROM sum_per_store
Order by Total_sales_amount DESC


-- WHAT'S THE TOTAL SALES OF LAST YEAR PER MONTH
--- The most profitable month of 2022 is august with 41M Sales amounts

WITH CTE_2022 AS( SELECT
  Extract(Year FROM Date) as Year,
  Extract(Month FROM Date) as Month,
  ROUND(AVG(Sale_dollars),2) as AVG_sales,
  ROUND(SUM(Sale_dollars),2) as Total_sales,
  ROUND(MAX(Sale_dollars),2) as MAX_sales
FROM `bigquery-public-data.iowa_liquor_sales.sales`
GROUP BY Year, Month)

SELECT *
FROM CTE_2022
WHERE Year = 2022

-- sales per month from 2023 
-- ON Average Sales Sept month is the most profitable month 
-- But total Sales Dec month is the most profitable month with 373M

---


SELECT
date,
sum(

CASE WHEN invoice_and_item_number like '%INV%' THEN state_bottle_cost ELSE 0 END

) AS inv_Amount_INV,

sum(

CASE WHEN invoice_and_item_number like '%S%' THEN state_bottle_cost ELSE 0 END

) AS S_Item_COUNT,

RANK() OVER (ORDER BY state_bottle_cost DESC) as RANKING

FROM `bigquery-public-data.iowa_liquor_sales.sales`
GROUP BY date,state_bottle_cost
ORDER BY RANKING ASC

#########


/* select*
from `bigquery-public-data.iowa_liquor_sales.sales`
*/

/* we can use an analytic function to calculate the cumulative number of store from  2015.
# Query to count the (cumulative) number of stores per year */

   WITH CTE_2022 AS( 
      SELECT DATE( date) as Date,
      COUNT(*) as num_store
      FROM `bigquery-public-data.iowa_liquor_sales.sales`
      WHERE EXTRACT(Year FROM date) = 2022
      GROUP BY  Date)
       
        SELECT *,
         sum(num_store) 
            OVER (
              ORDER BY  Date
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS cumulative_stores
     FROM CTE_2022
                     


SELECT 
      date,
      FIRST_VALUE(item_description)
      OVER (
      PARTITION BY item_number
      ORDER BY date
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS item_name,
      LAST_VALUE(store_name)
      OVER (
       PARTITION BY store_number
      ORDER BY date
       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS store_id,
      sale_dollars,
      state_bottle_cost
 FROM `bigquery-public-data.iowa_liquor_sales.sales`
 WHERE date = '2022-05-06' 
 
  
  
