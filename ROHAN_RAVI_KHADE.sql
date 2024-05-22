use ORDERS;
/* 1. Write a query to display customer full name with their title (Mr/Ms), both first name and lASt name are in upper CASE, 
	  customer email id, customer creation date and display customer’s categORy after applying below categORization rules: 
		i) IF customer creation date Year <2005 THEN CategORy A  
		ii) IF customer creation date Year >=2005 and <2011 THEN CategORy B
		iii) IF customer creation date Year>= 2011 THEN CategORy C */

SELECT * from ONLINE_CUSTOMER;
SELECT 
	CASE CUSTOMER_GENDER
		WHEN CUSTOMER_GENDER = 'F' THEN 'Ms.'
		ELSE 'Mr.'
        END AS TITLE,
	UPPER(CUSTOMER_FNAME) AS 'FIRST NAME',
	UPPER(CUSTOMER_LNAME) AS 'LAST NAME',
	CUSTOMER_EMAIL,
	CUSTOMER_CREATION_DATE,
	CUSTOMER_GENDER,
	CASE
		WHEN CUSTOMER_CREATION_DATE < '2005-01-01' THEN 'CATEGORY A'
        WHEN CUSTOMER_CREATION_DATE >= '2005-01-01' AND CUSTOMER_CREATION_DATE < '2011-01-01' THEN 'CATEGORY B'
        WHEN CUSTOMER_CREATION_DATE >= '2011-01-01' THEN 'CATEGORY C'
	END AS CATEGORY
	FROM ONLINE_CUSTOMER;
    
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 2. Write a query to display the following infORmation fOR the products, which have not been sold: product_id, product_desc, product_quantity_avail, product_price, 
inventORy values (product_quantity_avail*product_price), New_Price after applying discount AS per below criteria. SORt the output with respect to decreASing value 
of InventORy_Value. 
	i) IF Product Price > 20,000 THEN apply 20% discount 
	ii) IF Product Price > 10,000 THEN apply 15% discount 
	iii) IF Product Price =< 10,000 THEN apply 10% discount */

SELECT * FROM PRODUCT;
SELECT P.PRODUCT_ID, P.PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, P.PRODUCT_PRICE, (PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE,
	CASE
		WHEN P.PRODUCT_PRICE > 20000 THEN (P.PRODUCT_PRICE - (P.PRODUCT_PRICE*0.20))
        WHEN P.PRODUCT_PRICE > 10000 THEN (P.PRODUCT_PRICE - (P.PRODUCT_PRICE*0.15))
        WHEN P.PRODUCT_PRICE <= 10000 THEN (P.PRODUCT_PRICE - (P.PRODUCT_PRICE*0.10))
        END AS NEW_PRICE
        FROM PRODUCT AS P
			LEFT JOIN ORder_items OI ON OI.PRODUCT_ID = P.PRODUCT_ID WHERE OI.PRODUCT_ID IS NULL
			ORDER BY INVENTORY_VALUE DESC;
        
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 3. Write a query to display Product_clASs_code, Product_clASs_description, Count of Product type in each product clASs, InventORy Value
(product_quantity_avail*product_price).
InfORmation should be displayed fOR only those product_clASs_code which have mORe than 1,00,000. InventORy Value. SORt the output with respect to decreASing value of
InventORy_Value.*/

SELECT * FROM PRODUCT;
SELECT * FROM PRODUCT_CLASS;
	SELECT
		P.PRODUCT_CLASS_CODE, PC.PRODUCT_CLASS_DESC, COUNT(PC.PRODUCT_CLASS_CODE) AS PRODUCT_COUNT, PC.PRODUCT_CLASS_CODE,
		SUM(PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE
		FROM PRODUCT AS P
		LEFT JOIN PRODUCT_CLASS AS PC ON PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
			GROUP BY PRODUCT_CLASS_DESC
			HAVING INVENTORY_VALUE > 100000
			ORDER BY INVENTORY_VALUE DESC;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    
/* 4. Write a query to display customer_id, full name, customer_email, customer_phone and country of 
customers who have cancelled all the ORders placed by them (USE SUBQUERY). */

SELECT * FROM ONLINE_CUSTOMER;
SELECT * FROM ADDRESS;
SELECT * FROM ORDER_HEADER;
	SELECT C.CUSTOMER_ID, CONCAT(C.CUSTOMER_FNAME,' ',C.CUSTOMER_LNAME) AS 'FULL_NAME', C.CUSTOMER_EMAIL, C.CUSTOMER_PHONE, C.ADDRESS_ID,
		A.COUNTRY, O.CUSTOMER_ID, O.ORDER_STATUS
		FROM ORDER_HEADER AS O
		LEFT JOIN ONLINE_CUSTOMER AS C ON O.CUSTOMER_ID = C.CUSTOMER_ID
		LEFT JOIN ADDRESS AS A ON A.ADDRESS_ID = C.ADDRESS_ID
			WHERE O.CUSTOMER_ID IN (SELECT CUSTOMER_ID FROM ORDER_HEADER WHERE ORDER_STATUS = 'CANCELLED')
			GROUP BY O.CUSTOMER_ID HAVING COUNT(DISTINCT O.ORDER_STATUS) = 1;
        
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city and number of consignments 
delivered to that city fOR Shipper DHL.*/

SELECT * FROM SHIPPER;
SELECT * FROM ORDER_HEADER;
SELECT * FROM ONLINE_CUSTOMER;
SELECT * FROM ADDRESS;
	SELECT S.SHIPPER_NAME, A.ADDRESS_ID, A.CITY, COUNT(C.CUSTOMER_ID) AS 'CUSTOMER_COUNT', C.ADDRESS_ID
				FROM SHIPPER AS S
					LEFT JOIN ORDER_HEADER AS O on S.SHIPPER_ID = O.SHIPPER_ID
					LEFT JOIN ONLINE_CUSTOMER AS C on O.CUSTOMER_ID = C.CUSTOMER_ID
					LEFT JOIN ADDRESS AS A ON A.ADDRESS_ID = C.ADDRESS_ID
						WHERE SHIPPER_NAME LIKE 'DHL'
						GROUP BY A.CITY;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 6. Write a query to display product_id, product_desc, product_quantity_avail, QUANTITY SOLD and show INVENTORY Status of products AS below AS per below condition:
	i. FOR ELECTRONICS and COMPUTER CATEGORIES,
		if sales till date is Zero THEN show 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
		if INVENTORY quantity is less than 10% of QUANTITY SOLD, show 'LOW INVENTORY, NEED TO ADD INVENTORY',
		if INVENTORY quantity is less than 50% of QUANTITY SOLD, show 'MEDIUM INVENTORY, need to add some inventORy',
		if INVENTORY quantity is mORe OR equal to 50% of QUANTITY SOLD, show 'SUFFICIENT INVENTORY' 
	ii. FOR MOBILES and WATCHES CATEGORIES,
		if sales till date is Zero THEN show 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        if INVENTORY quantity is less than 20% of QUANTITY SOLD, show 'LOW INVENTORY, NEED TO ADD INVENTORY',
        if INVENTORY quantity is less than 60% of QUANTITY SOLD, show 'MEDIUM INVENTORY, need to add some inventORy',
        if INVENTORY quantity is mORe OR equal to 60% of QUANTITY SOLD, show 'SUFFICIENT INVENTORY'
	Rest of the CATEGORIES,
		if sales till date is Zero THEN show 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        if INVENTORY quantity is less than 30% of QUANTITY SOLD, show 'LOW INVENTORY, NEED TO ADD INVENTORY',
		if INVENTORY quantity is less than 70% of QUANTITY SOLD, show 'MEDIUM INVENTORY, need to add some inventORy',
		if INVENTORY quantity is mORe OR equal to 70% of QUANTITY SOLD, show 'SUFFICIENT INVENTORY'*/

SELECT * FROM PRODUCT;
SELECT * FROM PRODUCT_CLASS;
SELECT * FROM ORDER_ITEMS;
	 SELECT P.PRODUCT_ID, P.PRODUCT_DESC, SUM(PRODUCT_QUANTITY_AVAIL) AS 'QUANTITY AVAILABLE', SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) AS 'QUANTITY SOLD', 
	      SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) AS 'AVAILABLE INVENTORY',
          
	CASE 	
		WHEN SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
		WHEN PC.PRODUCT_CLASS_DESC = 'ELECTRONICS' OR PC.PRODUCT_CLASS_DESC = 'COMPUTER' THEN
	CASE 
		WHEN SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) < 0.1* SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
		WHEN SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) < 0.5* SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) THEN 'MEDIUM INVENTORY'
		WHEN SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) >= 0.5* SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) THEN 'SUFFICIENT INVENTORY'
	END 
		WHEN PC.PRODUCT_CLASS_DESC = 'MOBILES' OR PC.PRODUCT_CLASS_DESC = 'WATCHES' THEN
	CASE 
		WHEN SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) < 0.2* SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
		WHEN SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) < 0.6* SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) THEN 'MEDIUM INVENTORY'
		WHEN SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) >= 0.6* SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) THEN 'SUFFICIENT INVENTORY'
	END 
		WHEN PC.PRODUCT_CLASS_DESC != 'MOBILES' OR PC.PRODUCT_CLASS_DESC !='WATCHES' OR PC.PRODUCT_CLASS_DESC != 'ELECTRONICS' OR PC.PRODUCT_CLASS_DESC != 'COMPUTER' THEN
	CASE 
		WHEN SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) < 0.3* SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
		WHEN SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) < 0.7* SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) THEN 'MEDIUM INVENTORY'
		WHEN SUM(PRODUCT_QUANTITY_AVAIL) - SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) >= 0.7* SUM(IFNULL(OI.PRODUCT_QUANTITY, 0)) THEN 'SUFFICIENT INVENTORY'
	END
	END AS 'INVENTORY STATUS'                          
	FROM PRODUCT AS P				
		LEFT JOIN PRODUCT_CLASS AS PC ON PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE
		LEFT JOIN ORDER_ITEMS AS OI ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY P.PRODUCT_ID
		ORDER BY PRODUCT_ID ASC;
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 */
SELECT * FROM ORDER_ITEMS;
SELECT * FROM CARTON;
SELECT * FROM PRODUCT;
	SELECT O.ORDER_ID, SUM(O.PRODUCT_QUANTITY * P.LEN * P.WIDTH * P.HEIGHT) AS PRODUCT_VOLUME FROM ORDER_ITEMS as O
		LEFT JOIN PRODUCT AS P ON P.PRODUCT_ID = O.PRODUCT_ID
		GROUP BY ORDER_ID HAVING 'PRODUCT_VOLUME' < (SELECT LEN*WIDTH*HEIGHT as 'CARTON VOLUME' FROM CARTON WHERE CARTON_ID = 10)
		ORDER BY PRODUCT_VOLUME DESC
		LIMIT 1;
        
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped
where mode of payment is Cash and customer last name starts with 'G'*/

SELECT * FROM ORDER_ITEMS;
SELECT * FROM PRODUCT;
SELECT * FROM ORDER_HEADER;
SELECT * FROM ONLINE_CUSTOMER;
	SELECT C.CUSTOMER_ID, CONCAT(C.CUSTOMER_FNAME,' ',C.CUSTOMER_LNAME) AS 'FULL_NAME',
		SUM(OI.PRODUCT_QUANTITY) AS 'TOTAL QUANTITY', SUM(P.PRODUCT_PRICE * OI.PRODUCT_QUANTITY) as 'TOTAL VALUE'
	from ONLINE_CUSTOMER as C  
		LEFT JOIN ORDER_HEADER AS OH ON OH.CUSTOMER_ID = C.CUSTOMER_ID
		LEFT JOIN ORDER_ITEMS AS OI ON OH.ORDER_ID = OI.ORDER_ID
		LEFT JOIN PRODUCT AS P ON P.PRODUCT_ID = OI.PRODUCT_ID
		WHERE OH.ORDER_STATUS = 'SHIPPED' AND OH.PAYMENT_MODE = 'CASH' AND C.CUSTOMER_LNAME LIKE '%G%'
		GROUP BY FULL_NAME;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 9. Write a query to display product_id, product_desc and total quantity of products which are sold together with product id 201 and are not shipped to city Bangalore and New
Delhi. Display the output in descending order with respect to the tot_qty.*/

SELECT * FROM ORDER_ITEMS;
SELECT * FROM PRODUCT;
SELECT * FROM ORDER_HEADER;
SELECT * FROM ONLINE_CUSTOMER;
	SELECT P.PRODUCT_ID AS PRODUCT_ID, P.PRODUCT_DESC AS PRODUCT_DESCRIPTION, SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY 
	FROM PRODUCT P
		LEFT JOIN ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID 
		WHERE OI.ORDER_ID IN (SELECT OI.ORDER_ID FROM ORDER_ITEMS
			LEFT JOIN ORDER_HEADER OH ON OH.ORDER_ID = OI.ORDER_ID
			LEFT JOIN ONLINE_CUSTOMER OC ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
			LEFT JOIN ADDRESS A ON A.ADDRESS_ID = OC.ADDRESS_ID
				WHERE PRODUCT_ID = 201 AND A.CITY != 'BANGALORE' AND A.CITY!= 'NEW DELHI')
					GROUP BY OI.ORDER_ID
					ORDER BY TOTAL_QUANTITY DESC;

/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* 10. Write a query to display the order_id,customer_id and customer fullname, total quantity of products shipped for order ids which are even and shipped to address
where pincode is not starting with "5".*/

SELECT * FROM ORDER_ITEMS;
SELECT * FROM ADDRESS;
SELECT * FROM ORDER_HEADER;
SELECT * FROM ONLINE_CUSTOMER;
	SELECT A.ADDRESS_ID AS ADDRESS_ID, OH.ORDER_ID AS ORDER_ID, OC.CUSTOMER_ID AS CUSTOMER_ID, CONCAT(CUSTOMER_FNAME,' ',CUSTOMER_LNAME) AS 'FULL_NAME',
            SUM(OI.PRODUCT_QUANTITY) as TOTAL_QUANTITY, A.PINCODE AS PINCODE
            FROM ONLINE_CUSTOMER OC
				LEFT JOIN ORDER_HEADER AS OH ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
                LEFT JOIN ORDER_ITEMS OI ON OI.ORDER_ID = OH.ORDER_ID
                LEFT JOIN ADDRESS A ON A.ADDRESS_ID = OC.ADDRESS_ID
					WHERE OH.ORDER_ID % 2 = 0 AND  A.PINCODE NOT LIKE '5%' AND OI.PRODUCT_QUANTITY IS NOT NULL
                    GROUP BY OC.CUSTOMER_ID;
/*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/