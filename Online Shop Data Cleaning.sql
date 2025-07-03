create database store_db;
use store_db;

create table customer(customer_id int,first_name text,last_name text,address text,email text,phone_number text);

alter table store_db.customer
add constraint primary key (customer_id);

describe customer;

select * from customer;

create table order_items(order_item_id int,	order_id int,	product_id int,	quantity int ,price_at_purchase int
);

describe order_items;

alter table store_db.order_items
add constraint primary key (order_item_id);



select * from order_items;

create table orders(order_id int,order_date int,customer_id int,total_price int
);

alter table store_db.orders
add constraint primary key (order_id);
select * from orders;

SELECT STR_TO_DATE(order_date, '%m/%d/%Y') 
FROM orders;

update store_db.orders
set order_date = STR_TO_DATE(order_date, '%m/%d/%Y');

create table payment(payment_id int,order_id int,payment_method varchar(100),amount int,transaction_status varchar(100)
);

alter table store_db.payment
add constraint primary key (payment_id);

select * from payment;

create table product(product_id int,product_name varchar(100),category varchar(100),price int,supplier_id int
);

alter table store_db.product
add constraint primary key (product_id);

create table reviews(review_id int,product_id int,customer_id int,rating int,review_text varchar(100),review_date date
);

alter table store_db.reviews
add constraint primary key (review_id);

create table shipments(shipment_id int,	order_id int,shipment_date date,carrier varchar(100),tracking_number varchar(100),delivery_date date,shipment_status varchar(100)
);

alter table store_db.shipments
add constraint primary key (shipment_id);

create table suppliers(supplier_id int,supplier_name varchar(100),contact_name varchar(100),address varchar(200),phone_number varchar(100),email varchar(100)
);

alter table store_db.suppliers
add constraint primary key (supplier_id);

select * from shipments;