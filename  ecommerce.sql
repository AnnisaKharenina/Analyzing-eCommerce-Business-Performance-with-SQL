Topic 1 Data Preparation
Topic 2 Annual Customer Growth Analysis
Topic 3 Annual Product Category Quality Analysis
Topic 4 Analysis of Annual Payment Type Usage

-- Topic 1

CREATE TABLE IF NOT EXISTS public.customers_dataset
(
    customer_id character varying COLLATE pg_catalog."default",
    customer_unique_id character varying COLLATE pg_catalog."default",
    customer_zip_code_prefix character varying COLLATE pg_catalog."default",
    customer_city character varying COLLATE pg_catalog."default",
    customer_state character varying COLLATE pg_catalog."default",
    PRIMARY KEY (customer_id)
);

CREATE TABLE IF NOT EXISTS public.geolocation_dataset
(
    geolocation_zip_code_prefix character varying COLLATE pg_catalog."default",
    geolocation_lat character varying COLLATE pg_catalog."default",
    geolocation_lng character varying COLLATE pg_catalog."default",
    geolocation_city character varying COLLATE pg_catalog."default",
    geolocation_state character varying COLLATE pg_catalog."default",
    PRIMARY KEY (geolocation_zip_code_prefix)
);

CREATE TABLE IF NOT EXISTS public.order_items_dataset
(
    order_id character varying COLLATE pg_catalog."default",
    order_item_id character varying COLLATE pg_catalog."default",
    product_id character varying COLLATE pg_catalog."default",
    seller_id character varying COLLATE pg_catalog."default",
    shipping_limit_date timestamp without time zone,
    price character varying COLLATE pg_catalog."default",
    freight_value character varying COLLATE pg_catalog."default",
    PRIMARY KEY (order_id)
);

CREATE TABLE IF NOT EXISTS public.order_payments_dataset
(
    order_id character varying COLLATE pg_catalog."default",
    payment_sequential character varying COLLATE pg_catalog."default",
    payment_type character varying COLLATE pg_catalog."default",
    payment_installments character varying COLLATE pg_catalog."default",
    payment_value character varying COLLATE pg_catalog."default",
    PRIMARY KEY (order_id)
);

CREATE TABLE IF NOT EXISTS public.order_reviews_dataset
(
    review_id character varying COLLATE pg_catalog."default",
    order_id character varying COLLATE pg_catalog."default",
    review_score smallint,
    review_comment_title character varying COLLATE pg_catalog."default",
    review_comment_message character varying COLLATE pg_catalog."default",
    review_creation_date timestamp without time zone,
    review_answer_timestamp time without time zone,
    PRIMARY KEY (order_id)
);

CREATE TABLE IF NOT EXISTS public.orders_dataset
(
    order_id character varying COLLATE pg_catalog."default",
    customer_id character varying COLLATE pg_catalog."default",
    order_status character varying COLLATE pg_catalog."default",
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone,
    PRIMARY KEY (order_id)
);

CREATE TABLE IF NOT EXISTS public.product_dataset
(
    no numeric,
    product_id character varying COLLATE pg_catalog."default",
    "product_category_name," character varying COLLATE pg_catalog."default",
    product_name_lenght numeric,
    product_description_lenght numeric,
    product_photos_qty numeric,
    product_weight_g numeric,
    product_length_cm numeric,
    product_height_cm numeric,
    product_width_cm numeric,
    PRIMARY KEY (product_id)
);

CREATE TABLE IF NOT EXISTS public.sellers_dataset
(
    seller_id character varying COLLATE pg_catalog."default",
    seller_zip_code_prefix character varying COLLATE pg_catalog."default",
    seller_city character varying COLLATE pg_catalog."default",
    seller_state character varying COLLATE pg_catalog."default",
    PRIMARY KEY (seller_id)
);

ALTER TABLE IF EXISTS public.geolocation_dataset
    ADD FOREIGN KEY (geolocation_zip_code_prefix)
    REFERENCES public.customers_dataset (customer_zip_code_prefix) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.geolocation_dataset
    ADD FOREIGN KEY (geolocation_zip_code_prefix)
    REFERENCES public.customers_dataset (customer_zip_code_prefix) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.order_items_dataset
    ADD FOREIGN KEY (order_id)
    REFERENCES public.orders_dataset (order_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.order_items_dataset
    ADD FOREIGN KEY (order_id)
    REFERENCES public.orders_dataset (order_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.order_payments_dataset
    ADD FOREIGN KEY (order_id)
    REFERENCES public.orders_dataset (order_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.orders_dataset
    ADD FOREIGN KEY (order_id)
    REFERENCES public.order_reviews_dataset (order_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.orders_dataset
    ADD FOREIGN KEY (customer_id)
    REFERENCES public.customers_dataset (customer_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.product_dataset
    ADD FOREIGN KEY (product_id)
    REFERENCES public.order_items_dataset (product_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.product_dataset
    ADD FOREIGN KEY (product_id)
    REFERENCES public.order_items_dataset (product_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.sellers_dataset
    ADD FOREIGN KEY (seller_id)
    REFERENCES public.order_items_dataset (seller_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.sellers_dataset
    ADD FOREIGN KEY (seller_id)
    REFERENCES public.order_items_dataset (seller_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.sellers_dataset
    ADD FOREIGN KEY (seller_zip_code_prefix)
    REFERENCES public.geolocation_dataset (geolocation_zip_code_prefix) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

END;

--Topic 2

-- soal 1

select 
	year, 
	round(avg(mau), 0) as average_mau
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		date_part('month', o.order_purchase_timestamp) as month,
		count(distinct c.customer_id) as mau
	from orders_dataset o 
	join customers_dataset c on o.customer_id = c.customer_id
	group by 1,2 
) subq
group by 1;

-- soal 2

select 
	date_part('year', first_purchase_time) as year,
	count(1) as new_customers
from (
	select 
		c.customer_id,
		min(o.order_purchase_timestamp) as first_purchase_time
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1
) subq
group by 1
order by 1;

-- soal 3

select 
	year, 
	count(distinct customer_unique_id) as repeating_customers
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as purchase_frequency
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1, 2
	having count(1) > 1
) subq
group by 1;

--soal 4

select 
	year, 
	round(avg(frequency_purchase),3) as avg_orders_per_customers 
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as frequency_purchase
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1, 2
) a
group by 1
order by 1;

--soal 5

with 
calc_mau as (
select 
	year, 
	round(avg(mau), 2) as average_mau
from
(
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		date_part('month', o.order_purchase_timestamp) as month,
		count(distinct c.customer_unique_id) as mau
	from orders_dataset o 
	join customers_dataset c on o.customer_id = c.customer_id
	group by 1,2 
) subq
group by 1
),

calc_repeat as (
select 
	year, 
	count(distinct customer_unique_id) as repeating_customers
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as purchase_frequency
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1, 2
	having count(1) > 1
) subq
group by 1
),

calc_avg_order as(
select 
	year, 
	round(avg(frequency_purchase),3) as avg_orders_per_customers 
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		c.customer_unique_id,
		count(1) as frequency_purchase
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1, 2
) a
group by 1
order by 1
),

calc_new as(
select 
	date_part('year', first_purchase_time) as year,
	count(1) as new_customers
from (
	select 
		c.customer_id,
		min(o.order_purchase_timestamp) as first_purchase_time
	from orders_dataset o 
	join customers_dataset c on c.customer_id = o.customer_id
	group by 1
) subq
group by 1
order by 1
)

select calc_mau.year, calc_mau.average_mau, calc_new.new_customers, calc_repeat.repeating_customers, calc_avg_order.avg_orders_per_customers 
from calc_mau
join calc_repeat on calc_mau.year = calc_repeat.year
join calc_avg_order on calc_mau.year = calc_avg_order.year
join calc_new on calc_mau.year = calc_new.year

END;

--Topic 3

-- NO 1 

create table total_revenue_per_year as
select 
	date_part('year', o.order_purchase_timestamp) as year,
	sum(revenue_per_order) as revenue
from (
	select 
		order_id, 
		sum(price+freight_value) as revenue_per_order
	from order_items_dataset
	group by 1
) subq
join orders_dataset o on subq.order_id = o.order_id
where o.order_status = 'delivered'
group by 1
order by 1;

-- NO 2

CREATE TABLE total_cancel_order_per_year AS
SELECT
	date_part('year',order_purchase_timestamp) as year,
	COUNT(1) AS total_cancel
FROM orders_dataset
WHERE order_status = 'canceled'
GROUP BY 1
ORDER BY 1;

-- NO 3

create table top_product_category_by_revenue_per_year as 
select 
	year, 
	product_category_name, 
	revenue 
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		p.product_category_name,
		sum(oi.price + oi.freight_value) as revenue,
		rank() over(
			partition by date_part('year', o.order_purchase_timestamp) 
	 order by 
	sum(oi.price + oi.freight_value) desc) as rk
	from order_items_dataset oi
	join orders_dataset o on o.order_id = oi.order_id
	join product_dataset p on p.product_id = oi.product_id
	where o.order_status = 'delivered'
	group by 1,2
) sq
where rk = 1;

-- NO 4

create table top_product_category_by_cancel_per_year as 
select 
	year, 
	product_category_name, 
	total_cancel 
from (
	select 
		date_part('year', o.order_purchase_timestamp) as year,
		p.product_category_name,
		count(1) as total_cancel,
		rank() over(
			partition by date_part('year', o.order_purchase_timestamp) 
	 order by 
	count(1) desc) as rk
	from order_items_dataset oi
	join orders_dataset o on o.order_id = oi.order_id
	join product_dataset p on p.product_id = oi.product_id
	where o.order_status = 'canceled'
	group by 1,2
) sq
where rk = 1;

-- NO 5

SELECT
	ry.year,
	try.product_category_name AS category_most_revenue,
	try.revenue AS most_revenue,
	ry.revenue AS total_revenue_per_year,
	tcy.product_category_name AS category_most_cancel,
	tcy.total_cancel AS num_most_cancel,
	cpy.count AS total_cancel
FROM total_revenue_per_year AS ry
JOIN total_cancel_order_per_year AS cpy ON ry.year=cpy.year
JOIN top_product_category_by_revenue_per_year AS try ON try.year=ry.year
JOIN top_product_category_by_cancel_per_year AS tcy ON tcy.year=ry.year
group by 1,2,3,4,5,6;

END;

-- Topic 4

--no 1

SELECT
	payment_type,
	COUNT(1) AS total_use_payment_type
from order_payments_dataset
GROUP BY 1
ORDER BY total_use_payment_type DESC;

--no 2

SELECT  payment_type,
		SUM(CASE 
				WHEN date_part('year', order_purchase_timestamp) = '2016' 
				THEN 1
				END
		   ) AS year_2016,
		SUM(CASE 
				WHEN date_part('year', order_purchase_timestamp) = '2017' 
				THEN 1
				END
		   ) AS year_2017,	   	   	   
		SUM(CASE 
				WHEN date_part('year', order_purchase_timestamp) = '2018' 
				THEN 1
				END
		   ) AS year_2018
		 
FROM order_payments_dataset OP
		JOIN orders_dataset O ON O.order_id = OP.order_id
GROUP BY payment_type;

with 
tmp as (
select 
	date_part('year', o.order_purchase_timestamp) as year,
	op.payment_type,
	count(1) as num_used
from order_payments_dataset op 
join orders_dataset o on o.order_id = op.order_id
group by 1, 2
) 

select *,
	case when year_2017 = 0 then NULL
		else round((year_2018 - year_2017) / year_2017, 2)
	end as pct_change_2017_2018
from (
select 
  payment_type,
  sum(case when year = '2016' then num_used else 0 end) as year_2016,
  sum(case when year = '2017' then num_used else 0 end) as year_2017,
  sum(case when year = '2018' then num_used else 0 end) as year_2018
from tmp 
group by 1) subq
order by 5 desc

END;
