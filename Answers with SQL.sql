SELECT TOP (1000) [customer_id]
      ,[age]
      ,[gender]
      ,[item_purchased]
      ,[category]
      ,[purchase_amount]
      ,[location]
      ,[size]
      ,[color]
      ,[season]
      ,[review_rating]
      ,[subscription_status]
      ,[shipping_type]
      ,[discount_applied]
      ,[previous_purchases]
      ,[payment_method]
      ,[frequency_of_purchases]
      ,[age_group]
      ,[purchase_frequency_days]
  FROM [test_env].[dbo].[processed_Customer_data]

select * from processed_Customer_data;
--revenue by gender
select gender, SUM(purchase_amount) from processed_Customer_data
group by gender;
--customers used a discount but still paid morethan average amount
select customer_id,purchase_amount
from processed_Customer_data
where discount_applied = 'Yes' and purchase_amount >= (select avg(purchase_amount) from processed_Customer_data)

--top 5 porducts with the highest average review rating.

select top 5 item_purchased, ROUND(AVG(review_rating),2) as Avg_review_ratings
from processed_Customer_data
group by item_purchased
order by AVG(review_rating) desc;

--compare the average purchase amounts b/w Standard and express shipping

select shipping_type, AVG(purchase_amount) as avg_purchase_amount
from processed_Customer_data
where shipping_type in ('Express', 'Standard')
group by shipping_type;

--segment customers in to new, retrning adn loyal and produce no of counts in each segment
with segCustCte as (
select customer_id, previous_purchases,
case when previous_purchases > 10 then 'Loyal'
	 when previous_purchases >= 2 and previous_purchases <= 10 then 'Returning'	
	 else 'new'
	 End   as Customer_Segmentation
from processed_Customer_data)
select Customer_Segmentation, COUNT(customer_id) as CountSegments
from segCustCte
group by Customer_Segmentation
order by CountSegments desc;

--top 3 most purchased products in each category
with itempurcte as (
select 
		category, item_purchased,
		COUNT(item_purchased) as noofproducts,
		ROW_NUMBER() over(Partition by category order by COUNT(item_purchased) desc) as rn
from processed_Customer_data
group by category, item_purchased
)
select rn,category, item_purchased, noofproducts
from itempurcte
where rn<=3


-- customers whoa re repeat buyers >5 purchases also likely to subscribe
with satiscte as (
select customer_id, previous_purchases,subscription_status,
	   case when previous_purchases>5 and subscription_status = 'Yes' then 'Satisfied'
	        when previous_purchases > 5 and subscription_status = 'No' then 'Non-Satisfied'
			else  'Not-repetitive'
			end
			as index_Satisfaction
from processed_Customer_data)
select subscription_status, index_Satisfaction, COUNT(customer_id) as noofcustomer
from satiscte
group by subscription_status, index_Satisfaction

--What is the revenue contributon of each age group

select age_group, SUM(purchase_amount) as total_revenue
from processed_Customer_data
group by age_group
order by total_revenue desc





