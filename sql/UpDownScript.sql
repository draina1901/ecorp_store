-- Check if the database 'ist659draina' exists; if not, create it
if not exists(select * from sys.databases where name='ist659draina')
    create database IST659draina
GO

use ist659draina
GO

--DOWN
--drop tables

drop table if exists orders
drop table if exists shipping_methods
drop table if exists order_status
drop table if exists product_storage_capacity_mapping
drop table if exists storage_capacities
drop table if exists products
drop table if exists product_models
drop table if exists product_types
drop table if exists product_colors
drop table if exists availability_status
drop table if exists cloud_subscriptions
drop table if exists payment_status
drop table if exists customers
drop table if exists payment_methods
drop table if exists subscription_status
drop table if exists cloud_plan_feature_mapping
drop table if exists plan_features
drop table if exists cloud_plans
drop table if exists cloud_storage_capacities
drop table if exists addresses


GO
--UP Metadata

--Create database tables 
-- creating look up table for address
create table addresses (
id int identity not null,
street varchar(15) not null,
region varchar(15) not null,
city varchar(15) not null,
country varchar(15) not null
constraint pk_address_id primary key (id)
)

-- creating lookup table for cloud storage capacities
create table cloud_storage_capacities(
    name varchar(255),
    constraint pk_storage_capacity_name primary key (name)
)

-- creating look up table for cloud plans
create table cloud_plans(
    id int identity not null,
    name varchar(255) not null,
    description varchar(255),
    price float not null,
    storage_capacity varchar(255) not null,
    billing_cycle varchar(20) not null,
    constraint pk_cloud_plan_id primary key (id),
    constraint fk_storage_capacity foreign key (storage_capacity)
        references cloud_storage_capacities (name)
)

--creating a unique constraint for cloud plans
alter table cloud_plans add
    constraint uc_cloud_plan unique (name, storage_capacity)

-- creating table for plan features
create table plan_features(
    id int identity not null,
    name varchar(100) not null,
    constraint pk_feature_id primary key (id)
)

--creating bridging table
create table cloud_plan_feature_mapping(
    cloud_plan_id int not null,
    feature_id int not null,
    constraint pk_cloud_plan_feature_id primary key (cloud_plan_id,feature_id),
    constraint fk_cloud_plans_id foreign key (cloud_plan_id)
        references cloud_plans (id),
    constraint fk_feature_id foreign key (feature_id)
        references plan_features (id)
)

-- creating subscription status lookup table
create table subscription_status(
    name varchar(255) not null,
    constraint pk_subscription_status primary key (name)
)

-- creating table for payment methods
create table payment_methods(
    name varchar(15) not null,
    constraint pk_payment_method primary key (name)
)

-- creating table for customers
create table customers(
    id int identity not null,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    date_of_birth date,
    email_address varchar(100),
    gender char(20),
    contact_number char(10) not null,
    primary_address_id int ,
    shipping_address_id int ,
    payment_method varchar(15) ,
    subscription_status varchar(255),
    delivery_date date ,
    order_date date ,
    plan_id int ,
    constraint pk_customer_id primary key (id),
    constraint fk_primary_address_id foreign key (primary_address_id)
        references addresses (id),
    constraint fk_shipping_address_id foreign key (shipping_address_id)
        references addresses (id),
    constraint fk_payment_method foreign key (payment_method)
        references payment_methods (name),
    constraint fk_subscription_status foreign key (subscription_status)
        references subscription_status (name),
    constraint fk_plan_id foreign key (plan_id)
        references cloud_plans (id)
)

-- altering the table and creating constraints
alter table customers add
    constraint uc_customer unique (email_address),
    constraint chk_phone_number_length check (len(contact_number) = 10 AND contact_number LIKE '[0-9]%'),
    constraint chk_delivery_order_date check ((order_date) <=(delivery_date))

-- creating a table for payment status
create table payment_status(
    name varchar(255) not null,
    constraint pk_payment_status_name primary key (name)
)

-- creating table for cloud subscriptions
create table cloud_subscriptions(
    id int identity not null,
    start_date date not null,
    end_date date,
    payment_status varchar(255) not null,
    plan_id int not null,
    customer_id int not null,
    constraint pk_subscription_id primary key (id),
    constraint fk_payment_status foreign key (payment_status)
        references payment_status(name),
    constraint fk_cloud_plan_id foreign key (plan_id)
        references cloud_plans (id), 
    constraint fk_customer_id foreign key (customer_id)
     references customers (id)
)

-- altering the cloud subscription table
alter table cloud_subscriptions add
    constraint uc_subscription unique (start_date, customer_id),
    constraint ck_start_end_date check (start_date < end_date)

-- creating table for availability status
create table availability_status(
    name varchar(255) not null,
    constraint pk_availability_status primary key (name)
)

-- creating lookup table for product colors
create table product_colors(
    name varchar(255) not null,
    constraint pk_product_color primary key (name)
)

-- creating lookup table for product types
create table product_types(
    name varchar(255) not null,
    constraint pk_product_type primary key (name)
)

-- creating lookup table for product models        
create table product_models(
    name varchar(255) not null,
    constraint pk_model_name primary key (name)
)

-- creating table for products
create table products(
    id int identity not null,
    name varchar(255) not null,
    type varchar(255) not null,
    color varchar(255) not null,
    availability_status varchar(255) not null,
    ram varchar(50) not null,
    price float not null,
    constraint pk_product_id primary key (id),
    constraint fk_product_model_name foreign key (name)
        references product_models (name),
    constraint fk_product_type foreign key (type)
        references product_types (name),
    constraint fk_product_color foreign key (color)
        references product_colors (name),
    constraint fk_availability_status foreign key (availability_status)
        references availability_status (name)
)

alter table products
add constraint uc_product_name_type unique (name, type);

-- creating table for storage capacities
create table storage_capacities(
    id int identity not null,
    capacity_type varchar(100) not null,
    constraint pk_storage_capacity_type primary key (id)
)

-- creating bridging table
create table product_storage_capacity_mapping (
    product_id int not null,
    capacity_id int not null,
    constraint pk_product_storage_capacity_id primary key (product_id,capacity_id),
    constraint fk_products_id foreign key (product_id)
        references products (id),
    constraint fk_capacity_id foreign key (capacity_id)
        references storage_capacities (id)
)

-- creating table for order status
create table order_status(
    name varchar(100) not null,
    constraint pk_order_status primary key (name)
)

-- creating table for shipping methods
create table shipping_methods(
    name varchar (100) not null,
    constraint pk_shipping_method primary key (name)
)

-- creating orders table
create table orders(
    id int identity not null,
    quantity int not null,
    order_status varchar(100) not null,
    total_price float not null,
    shipping_address_id int not null,
    billing_address_id int not null,
    payment_method varchar(15) not null,
    shipping_method varchar(100) not null,
    customer_id int not null,
    product_id int not null,
    delivery_date date,
    constraint pk_order_id primary key (id),
    constraint fk_order_status foreign key (order_status)
        references order_status (name),
    constraint fk_shipping_add_id foreign key (shipping_address_id)
        references addresses (id),
    constraint fk_billing_address_id foreign key (billing_address_id)
        references addresses (id),
    constraint fk_payments_method foreign key (payment_method)
        references payment_methods (name),
    constraint fk_shipping_method foreign key (shipping_method)
        references shipping_methods (name),
    constraint fk_customers_id foreign key (customer_id)
        references customers (id),
    constraint fk_prdct_id foreign key (product_id)
        references products (id)
)

alter table orders
add constraint uc_order_customer_product_delivery unique (customer_id, product_id, delivery_date);


--Load Data Script

-- UP DATA

-- inserting data into addresses column
insert into addresses (street,region,city,country)
    values ('321 westcott','NY','Syracuse','USA'),
            ('322 westcott','NY','Syracuse','USA'),
            ('323 westcott','NY','Syracuse','USA'),
            ('333 westcott','NY','Syracuse','USA'),
            ('820 westcott','NY','Syracuse','USA'),
            ('670 westcott','NY','Syracuse','USA'),
            ('200 westcott','NY','Syracuse','USA'),
            ('1733 N First St','CA','San Jose','USA'),
            ('1720 N First St','CA','San Jose','USA'),
            ('1739 N First St','CA','San Jose','USA'),
            ('1711 N First St','CA','San Jose','USA'),
            ('320 Madison','NY','Syracuse','USA'),
            ('7th St','NJ','Harrison','USA'),
            ('13 Harrison Ave','AZ','Phoenix','USA')

-- inserting data into cloud storage table
insert into cloud_storage_capacities (name)
    values ('50GB'),
        ('100GB'),
        ('500GB'),
        ('1TB'),
        ('5TB'),
        ('Customizable')

-- inserting data into cloud plans table
insert into cloud_plans (name,description,price,storage_capacity,billing_cycle)
    values ('Basic Cloud','Ideal for personal use',	5.99,'100GB','Monthly'),
        ('Free Tier','For Beginners',0.00,'50GB','Monthly'),
        ('Business Cloud','Suitable for small businesses',19.99,'500GB','Monthly'),
        ('Enterprise Cloud','For large organizations with heavy usage',99.99,'5TB','Monthly'),
        ('Premium Cloud','Premium features for power users',49.99,'1TB','Monthly')
     --   ('Custom Cloud','Tailored to your specific needs',20.99,null,null)

-- inserting data into plan features table
insert into plan_features (name)
    values('File Syncing'),
        ('File Sharing'),
        ('Versioning'),
        ('Backup and Restore'),
        ('Offline Access'),
        ('Customer Support')

-- inserting data into bridging table
insert into cloud_plan_feature_mapping (cloud_plan_id,feature_id)
    values(1,1),
        (1,2),
        (1,3),
        (2,4),
        (2,5),
        (3,6),
        (3,1),
        (4,4),
        (5,4)

-- inserting data into subscription status table
insert into subscription_status (name)
    values ('Active'),
        ('Inactive'),
        ('Pending'),
        ('Canceled'),
        ('Suspended'),
        ('Trial')

-- inserting data into payment methods table
insert into payment_methods (name)
    values ('Credit Card'),
        ('Debit Card'),
        ('Bank Transfer'),
        ('PayPal'),
        ('Apple Pay'),
        ('Google Pay'),
        ('COD')

-- inserting data into customers table
insert into customers (first_name,last_name,date_of_birth,email_address,gender,contact_number,primary_address_id,shipping_address_id,payment_method,subscription_status,order_date,delivery_date,plan_id)
    values('Diksha','Raina','01/19/1994','draina@gmail.com','Female','3159019638','1','1','Debit Card','Active','09/12/2023','09/25/2023',1),
        ('Priyanka','Raina','04/21/1992','praina@gmail.com','Female','8600610542','2','3','Credit Card','Inactive','09/12/2023','09/25/2023',2),
        ('Harsha','Hangloo','06/25/1994','harsha12@gmail.com','Female','8677890123','4','4','PayPal','Active','09/01/2023','09/15/2023',4),
        ('James','Bond','01/11/1894','jbond@gmail.com','Male','3159019699','5','5','Google Pay','Active','09/11/2023','09/15/2023',3),
        ('Chandler','Bing','11/15/1894','cbing@gmail.com','Male','3158764522','6','6','Apple Pay','Active','09/23/2023','09/25/2023',1),
        ('Monica','Geller','03/29/1984','mgeller@gmail.com','Female','3159019618','7','8','Debit Card','Active','09/08/2023','09/25/2023',5),
        ('Rachel','Green','02/19/1954','rgreen@gmail.com','Female','9089019638','9','9','Debit Card','Active','09/06/2023','09/08/2023',1),
        ('Ross','Geller','01/20/1955','rgeller@gmail.com','Male','8859019638','10','10','Bank Transfer','Active','08/12/2023','08/25/2023',4)

-- inserting data into payment status table
insert into payment_status (name)
    values('Pending'),
        ('Processing'),
        ('Authorized'),
        ('Completed'),
        ('Failed'),
        ('Canceled'),
        ('Refunded'),
        ('On Hold'),
        ('Expired')

-- inserting data into cloud subscription table
insert into cloud_subscriptions(start_date,end_date,payment_status,plan_id,customer_id)
    values('05/20/2020', null, 'Completed', 1,1),
    ('06/01/2020', null, 'Canceled', 2,2),
    ('03/20/2021', null, 'Completed', 3,4),
    ('08/02/2022', null, 'Completed', 4,3),
    ('10/06/2023', null, 'Authorized', 5,6),
    ('02/20/2024', null, 'Pending', 5,5)

-- inserting data into availability table
insert into availability_status (name)
    values('In Stock'),
        ('Out Of Stock')

-- inserting data into product colors table
insert into product_colors(name)
    values('Black'),
        ('Space Grey'),
        ('Golden'),
        ('Lavender'),
        ('Sky Blue'),
        ('Rose Pink'),
        ('White'),
        ('Green'),
        ('Graphite')

-- inserting data into product types table
insert into product_types (name)
    values('Laptop'),
        ('Phone'),
        ('Tablet'),
        ('PC')

-- inserting data into product models table
insert into product_models(name)
    values('ECorp Pulse'),
        ('ECorp Fusion'),
        ('ECorp Spark'),
        ('ECorp Blaze'),
        ('ECorp NovaBook'),
        ('ECorp EdgeBook'),
        ('ECorp FusionBook'),
        ('ECorp QuantumBook'),
        ('ECorp GlideTab'),
        ('ECorp StreamTab'),
        ('ECorp NovaTab'),
        ('ECorp PixelTab'),
        ('ECorp PowerTower'),
        ('ECorp ProDesk'),
        ('ECorp UltraTech'),
        ('ECorp CoreStation')

-- inserting data into products table
insert into products (name,type,color,availability_status,ram,price)
    values('ECorp Pulse','Phone','White','In Stock','2GB',300),
        ('ECorp Fusion','Phone','Space Grey','In Stock','8GB',600),
        ('ECorp Spark','Phone','Rose Pink','In Stock','2GB',350),
        ('ECorp Blaze','Phone','Black','In Stock','4GB',500),
        ('ECorp NovaBook','Laptop','Lavender','In Stock','8GB',700),
        ('ECorp EdgeBook','Laptop','Sky Blue','In Stock','16GB',900),
        ('ECorp FusionBook','Laptop','White','Out Of Stock','8GB',650),
        ('ECorp QuantumBook','Laptop','White','In Stock','32GB',1000),
        ('ECorp GlideTab','Tablet','Rose Pink','In Stock','2GB',250),
        ('ECorp StreamTab','Tablet','White','In Stock','4GB',450),
        ('ECorp Pulse','Tablet','White','In Stock','8GB',650),
        ('ECorp NovaTab','Tablet','Graphite','Out Of Stock','2GB',300),
        ('ECorp PixelTab','Tablet','Sky Blue','In Stock','16GB',700),
        ('ECorp PowerTower','PC','White','In Stock','8GB',1100),
        ('ECorp ProDesk','PC','Lavender','In Stock','8GB',1250),
        ('ECorp UltraTech','PC','White','In Stock','16GB',1300),
        ('ECorp CoreStation','PC','White','In Stock','8GB',1100)

-- inserting data into storage capacities table
insert into storage_capacities(capacity_type)
    values('32GB'),
        ('64GB'),
        ('128GB'),
        ('256GB'),
        ('512GB'),
        ('1TB'),
        ('2TB'),
        ('4TB')

-- inserting data into bridging table
insert into product_storage_capacity_mapping(product_id,capacity_id)
    values(1,1),
        (1,2),
        (1,3),
        (1,4),
        (2,2),
        (2,3),
        (3,1),
        (3,2),
        (4,2),
        (4,3),
        (5,4),
        (6,2),
        (6,5),
        (7,3),
        (7,2),
        (8,3),
        (8,4),
        (9,2),
        (10,1),
        (11,2),
        (12,3),
        (13,1),
        (14,2),
        (15,3),
        (16,6),
        (17,7)

-- inserting data into order status table
insert into order_status (name)
    values('Pending'),
        ('Processing'),
        ('Shipped'),
        ('In Transit'),
        ('Delivered'),
        ('Cancelled')

-- inserting data into shipping methods table
insert into shipping_methods(name)
    values('Standard Shipping'),
        ('Express Shipping'),
        ('Same-Day Shipping'),
        ('Priority Shipping')

-- inserting data into orders table
insert into orders (quantity,order_status,total_price,shipping_address_id,billing_address_id,payment_method,shipping_method,customer_id,product_id,delivery_date)
    values(2,'Pending',1000,1,1,'Debit Card','Standard Shipping',1,1,'03/20/2024'),
        (1,'shipped',1000,2,2,'Debit Card','Express Shipping',2,5,'03/09/2024'),
        (1,'Pending',1000,4,4,'Debit Card','Priority Shipping',3,3,'03/10/2024'),
        (2,'shipped',1000,5,5,'Debit Card','Express Shipping',4,2,'03/25/2024'),
        (3,'Delivered',1000,6,6,'Debit Card','Same-Day Shipping',5,3,'03/07/2024'),
        (1,'In Transit',1000,8,8,'Debit Card','Express Shipping',6,1,'03/11/2024'),
        (1,'Pending',1000,6,6,'Debit Card','Express Shipping',7,9,'03/12/2024'),
        (1,'Pending',1000,1,1,'Debit Card','Express Shipping',8,10,'03/11/2024')








---VERIFY

select * from addresses
select * from cloud_storage_capacities
select * from cloud_plans
select * from plan_features
select * from cloud_plan_feature_mapping
select * from subscription_status
select * from payment_methods
select * from customers
select * from payment_status
select * from cloud_subscriptions
select * from availability_status
select * from product_colors
select * from product_types
select * from products
select * from product_models
select * from storage_capacities
select * from product_storage_capacity_mapping
select * from order_status
select * from shipping_methods
select * from orders



/* creating view for customer order details */
drop view if exists v_Orderdetails
go

create view v_Orderdetails
as
select 
    c.first_name + ' ' + c.last_name as CustomerName,
    c.email_address as EmailID,
    o.id as OrderID,
    O.quantity as OrderQuantity,
    o.order_status as OrderStatus,
    o.total_price as TotalPrice,
    o.delivery_date as DeliveryDate
from customers c
left join orders o on c.id =o.customer_id

go 

--Demo of the view
select * from v_Orderdetails


---creating view to check customer cloud plan details

-- Drop the view if it already exists
drop view if exists CustomerCloudDetails
go

-- Create the view to show customer and their cloud details
create view CustomerCloudDetails
as
select
    c.id AS customer_id,
    c.first_name,
    c.last_name,
    c.date_of_birth,
    c.email_address,
    c.gender,
    cs.start_date AS subscription_start_date,
    cs.end_date AS subscription_end_date,
    cs.payment_status,
    cp.name AS plan_name,
    cp.description AS plan_description,
    cp.price AS plan_price,
    cp.storage_capacity AS plan_storage_capacity,
    cp.billing_cycle AS plan_billing_cycle
from
    customers c
join
    cloud_subscriptions cs ON c.id = cs.customer_id
left join
    cloud_plans cp ON cs.plan_id = cp.id;
go

--Select the view to check the details
select * from CustomerCloudDetails


--Create Account Procedure 


drop procedure if exists createcustacct;
go

create procedure createcustacct
    @first_name varchar(50),
    @last_name varchar(50),
    @email_address varchar(100),
    @date_of_birth date,
    @contact_number char(10),
    @gender char(20),
    @primary_address_id int,
    @shipping_address_id int
as
begin
    begin try
        -- Start a transaction
        begin transaction;

        -- Insert into the customers table
        insert into customers(first_name, last_name, email_address, date_of_birth, contact_number, gender, primary_address_id, shipping_address_id) 
        values(@first_name, @last_name, @email_address, @date_of_birth,
               @contact_number, @gender, @primary_address_id, @shipping_address_id);

        -- Commit the transaction if successful
        commit transaction;
    end try
    begin catch
        -- Rollback the transaction if an error occurs
        if @@trancount > 0
            rollback transaction;

        -- Optionally raise or handle the error
        declare @error_message nvarchar(max) = error_message();
        raiserror('Error occurred: %s', 16, 1, @error_message);
    end catch;
end;
go



-- Execute the CreateCustAcct procedure with specific parameter values


--If you add a new user details, the code will execute
exec CreateCustAcct
    @first_name = 'Sneha',
    @last_name = 'Mani',
    @email_address = 'Snehamani@gmail,com',
    @date_of_birth = '1990-05-15',
    @contact_number = '1234567890',
    @gender = 'Female',
    @primary_address_id = 2,
    @shipping_address_id = 2;




--selecting customers to check the customer creation procedure
select * from customers

/*
procedure to delete order 
*/

drop procedure if exists deleteorder;
go

-- Create procedure to delete an order by ID
create procedure deleteorder
    @order_id int
as
begin
    set nocount on;

    begin try
        -- Start a transaction
        begin transaction;

        -- Check if the order exists
        if exists (select 1 from orders where id = @order_id)
        begin
            -- Delete the order
            delete from orders where id = @order_id;
            print 'Order deleted successfully.';
        end
        else
        begin
            print 'Order not found.';
        end

        -- Commit the transaction if successful
        commit transaction;
    end try
    begin catch
        -- Rollback the transaction if an error occurs
        if @@trancount > 0
            rollback transaction;

        -- Optionally raise or handle the error
        declare @error_message nvarchar(max) = error_message();
        raiserror('Error occurred: %s', 16, 1, @error_message);
    end catch;
end;
go


-- Call the procedure to delete an order with ID 8
EXEC DeleteOrder @order_id = 8;

go


-- create procedure to update an order 
drop procedure if exists update_order;
go

create procedure update_order
    @order_id int,
    @new_payment_method varchar(15),
    @new_shipping_address_id int,
    @new_shipping_method varchar(100)
as
begin
    set nocount on;

    begin try
        -- Start a transaction
        begin transaction;

        -- Check if the order exists
        if exists (select 1 from orders where id = @order_id)
        begin
            -- Update the order
            update orders
            set 
                payment_method = @new_payment_method,
                shipping_address_id = @new_shipping_address_id,
                shipping_method = @new_shipping_method
            where id = @order_id;

            print 'order updated successfully.';
        end
        else
        begin
            print 'order not found.';
        end

        -- Commit the transaction if successful
        commit transaction;
    end try
    begin catch
        -- Rollback the transaction if an error occurs
        if @@trancount > 0
            rollback transaction;

        -- Optionally raise or handle the error
        declare @error_message nvarchar(max) = error_message();
        raiserror('Error occurred: %s', 16, 1, @error_message);
    end catch;
end;
go


---demonstration of procedure excecution
exec update_order
    @order_id = 1,
    @new_payment_method = 'Credit Card',
    @new_shipping_address_id = 2,
    @new_shipping_method = 'Priority Shipping';


--selceting orders to verify the procedure
select * from orders


drop procedure if exists addproduct;
go

-- Create the procedure to add a new product
create procedure addproduct
    @product_name varchar(255),
    @product_type varchar(255),
    @product_color varchar(255),
    @availability_status varchar(255),
    @ram varchar(50),
    @price float
as
begin
    begin try
        -- Start a transaction
        begin transaction;

        -- Insert into the products table
        insert into products (name, type, color, availability_status, ram, price)
        values (@product_name, @product_type, @product_color, @availability_status, @ram, @price);

        print 'New product added successfully.';

        -- Commit the transaction if successful
        commit transaction;
    end try
    begin catch
        -- Rollback the transaction if an error occurs
        if @@trancount > 0
            rollback transaction;

        -- Optionally raise or handle the error
        declare @error_message nvarchar(max) = error_message();
        raiserror('Error occurred: %s', 16, 1, @error_message);
    end catch;
end;
go





-- Drop the procedure if it already exists


drop procedure if exists deleteproduct;
go

-- Drop the procedure if it already exists
drop procedure if exists deleteproduct;
go

-- Create the procedure to delete an existing product
create procedure deleteproduct
    @product_id int
as
begin
    begin try
        -- Start a transaction
        begin transaction;

        -- Check if the product exists
        if not exists (select 1 from products where id = @product_id)
        begin
            print 'Product with ID ' + CAST(@product_id as varchar) + ' not found.';
        end
        else
        begin
            -- Delete from the products table
            delete from products where id = @product_id;

            -- Check if any rows were affected
            if @@ROWCOUNT > 0
                print 'Product deleted successfully.';
            else
                print 'Product with ID ' + CAST(@product_id as varchar) + ' not found.';
        end

        -- Commit the transaction if successful
        commit transaction;
    end try
    begin catch
        -- Rollback the transaction if an error occurs
        if @@trancount > 0
            rollback transaction;

        -- Check if the error is due to a foreign key constraint violation
        if error_number() = 547
            raiserror('Error: Cannot delete the product due to existing references in other tables.', 16, 1);
        else
        begin
            -- Optionally raise or handle other errors
            declare @error_message nvarchar(max) = error_message();
            raiserror('Error occurred: %s', 16, 1, @error_message);
        end
    end catch;
end;
go





-- Drop the procedure if it already exists
drop procedure if exists updateproduct;
go 

-- Create the procedure to update an existing product
create procedure updateproduct
    @product_id int,
    @product_name varchar(255) = null,
    @product_type varchar(255) = null,
    @product_color varchar(255) = null,
    @availability_status varchar(255) = null,
    @ram varchar(50) = null,
    @price float = null
as
begin
    begin try
        -- Start a transaction
        begin transaction;

        -- Update the products table
        update products
        set
            name = isnull(@product_name, name),
            type = isnull(@product_type, type),
            color = isnull(@product_color, color),
            availability_status = isnull(@availability_status, availability_status),
            ram = isnull(@ram, ram),
            price = isnull(@price, price)
        where id = @product_id;

        -- Check if any rows were affected
        if @@ROWCOUNT > 0
            print 'Product updated successfully.';
        else
            print 'Product with ID ' + cast(@product_id as varchar) + ' not found.';

        -- Commit the transaction if successful
        commit transaction;
    end try
    begin catch
        -- Rollback the transaction if an error occurs
        if @@trancount > 0
            rollback transaction;

        -- Optionally raise or handle the error
        declare @error_message nvarchar(max) = error_message();
        raiserror('Error occurred: %s', 16, 1, @error_message);
    end catch;
end;
go



--Demo of Add Product Procedure
EXEC AddProduct @product_name = 'ECorp Blaze', @product_type = 'Laptop', @product_color = 'White', @availability_status = 'In Stock', @ram = '8GB', @price = 499.99;


--Demo of Delete Product Procedure
EXEC DeleteProduct @product_id = 18;


--Demo of Update Product Procedure
EXEC UpdateProduct @product_id = 23, @product_name = 'ECorp NewPhone', @availability_status = 'Out Of Stock';


--Selecting Products to verify the procedures

select * from products




