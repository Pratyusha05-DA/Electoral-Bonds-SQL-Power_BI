use electoralbonddata;

select * from bankdata;
select * from bonddata;
select * from donordata;
select * from receiverdata;

/*------------  QUERIES  ------------*/

-- 1. Find out how much donors spent on bonds
SELECT SUM(denomination) AS total_spent_on_bonds
FROM bonddata b 
INNER JOIN donordata d
ON b.unique_key = d.Unique_key; 

-- 2. Find out total fund politicians got
SELECT SUM(denomination) AS total_funds_received
FROM bonddata b 
INNER JOIN receiverdata r
ON b.unique_key = r.Unique_key; 

-- 3. Find out the total amount of unaccounted money received by parties
SELECT SUM(b.denomination) AS total_unaccounted_money
FROM donordata d RIGHT JOIN receiverdata r 
ON d.unique_key = r.unique_key  
JOIN bonddata b ON b.unique_key = r.unique_key                            				  
WHERE purchaser IS NULL;

-- 4. Find year wise how much money is spent on bonds
SELECT YEAR(PurchaseDate) AS Year, SUM(denomination) AS total_spent_on_bonds
FROM donordata d 
INNER JOIN bonddata b
ON b.unique_key = d.Unique_key 
GROUP BY 1;  

-- 5. In which month most amount is spent on bonds
WITH monthlyspent AS (
SELECT MONTHNAME(PurchaseDate) AS _MONTH_ , SUM(denomination) AS total_spent,
ROW_NUMBER() OVER (ORDER BY SUM(denomination) DESC) AS rn
FROM donordata d 
INNER JOIN bonddata b
ON b.unique_key = d.Unique_key
GROUP BY 1 ORDER BY 2 DESC
)
SELECT _MONTH_ FROM monthlyspent
WHERE rn=1 ;   

SELECT MONTHNAME(PurchaseDate) AS _MONTH_ , SUM(denomination) AS total_spent_on_bonds
FROM donordata 
INNER JOIN bonddata
ON b.unique_key = d.Unique_key
GROUP BY 1 ORDER BY 2 DESC;

-- 6. Find out which company bought the highest number of bonds.
WITH counting AS (
SELECT purchaser, COUNT(d.unique_key) AS count,
ROW_NUMBER() OVER (ORDER BY COUNT(unique_key) DESC) AS rn FROM donordata d
INNER JOIN bonddata b 
ON b.unique_key = d.Unique_key 
GROUP BY 1 ORDER BY 2 DESC
)
SELECT purchaser FROM counting WHERE rn = 1; 

SELECT purchaser, COUNT(d.unique_key) AS count 
FROM donordata d
INNER JOIN bonddata b 
ON b.unique_key = d.Unique_key 
GROUP BY 1 ORDER BY 2 DESC;

-- 7. Find out which company spent the most on electoral bonds.
WITH counting AS (
SELECT purchaser, SUM(b.denomination) AS total_spent,
ROW_NUMBER() OVER (ORDER BY SUM(b.denomination) DESC) AS rn FROM donordata d
JOIN bonddata b ON b.unique_key = d.Unique_key 
GROUP BY 1 ORDER BY 2 DESC
)
SELECT purchaser FROM counting WHERE rn = 1; -- FUTURE GAMING AND HOTEL SERVICES PRIVATE LIMITED

SELECT purchaser, SUM(b.denomination) AS total_spent FROM donordata d
JOIN bonddata b ON b.unique_key = d.Unique_key 
GROUP BY 1 ORDER BY 2 DESC;

-- 8. List companies which paid the least to political parties.
WITH counting AS (
SELECT purchaser, SUM(b.denomination) AS total_spent,
ROW_NUMBER() OVER (ORDER BY SUM(b.denomination) DESC) AS rn FROM donordata d
JOIN bonddata b ON b.unique_key = d.Unique_key GROUP BY 1
)
SELECT purchaser AS Purchaser ,total_spent FROM counting 
WHERE total_spent = (SELECT MIN(total_spent) FROM counting) ;

-- 9. Which political party received the highest cash?
WITH highest_cash AS (
SELECT partyname, SUM(b.denomination) AS highest_cash_received,
ROW_NUMBER() OVER (ORDER BY SUM(b.denomination) DESC) AS rn FROM receiverdata r
JOIN bonddata b ON r.unique_key = b.Unique_key 
GROUP BY 1 ORDER BY 2 DESC
) 
SELECT partyname FROM highest_cash WHERE rn = 1 ; 

SELECT partyname, SUM(b.denomination) AS total_cash_received 
FROM receiverdata r JOIN bonddata b ON r.unique_key = b.Unique_key 
GROUP BY 1 ORDER BY 2 DESC ;

-- 10. Which political party received the highest number of electoral bonds?
WITH electoral AS (
SELECT PartyName, COUNT(b.Unique_key) AS de FROM receiverdata r
INNER JOIN bonddata b ON r.Unique_key = b.Unique_key GROUP BY 1
) 
SELECT PartyName FROM electoral
WHERE de = (SELECT MAX(de) FROM electoral); 

SELECT PartyName, COUNT(b.Unique_key) AS de FROM receiverdata r
INNER JOIN bonddata b ON r.Unique_key = b.Unique_key 
GROUP BY 1 ORDER BY de DESC;

-- 11. Which political party received the least cash?
WITH least_cash AS (
SELECT partyname, SUM(b.denomination) AS least_cash_received,
ROW_NUMBER() OVER (ORDER BY SUM(b.denomination) ASC) AS rn 
FROM receiverdata r JOIN bonddata b 
ON r.unique_key = b.unique_key 
GROUP BY 1 ORDER BY 2 ASC
)
SELECT partyname as PARTYNAME FROM least_cash 
WHERE rn = 1;  

SELECT partyname, SUM(b.denomination) AS least_cash_received 
FROM receiverdata r JOIN bonddata b 
ON r.unique_key = b.unique_key 
GROUP BY 1 ORDER BY 2;

-- 12. Which political party received the least number of electoral bonds?
WITH electoral AS (
SELECT Partyname, COUNT(b.unique_key) AS ct 
FROM receiverdata r JOIN bonddata b 
ON r.Unique_key = b.unique_key GROUP BY 1
)   
SELECT Partyname FROM electoral 
WHERE ct = (SELECT MIN(ct) FROM electoral);     

SELECT PartyName, COUNT(b.unique_key) AS ct 
FROM receiverdata r JOIN bonddata b 
ON r.Unique_key = b.unique_key 
GROUP BY 1 ORDER BY 2;

-- 13. Find the 2nd highest donor in terms of amount he paid?
SELECT purchaser, SUM(b.denomination) AS 2nd_highest 
FROM donordata d INNER JOIN bonddata b 
ON d.Unique_key = b.unique_key
GROUP BY 1 ORDER BY 2 DESC LIMIT 1,1;  

-- 14. Find the party which received the second highest donations?
SELECT PartyName, SUM(b.denomination) AS 2nd_highest 
FROM receiverdata r INNER JOIN bonddata b 
ON r.Unique_key = b.unique_key
GROUP BY 1 ORDER BY 2 DESC LIMIT 1,1;  

-- 15. Find the party which received the second highest number of bonds  
SELECT PartyName, COUNT(b.unique_key) AS 2nd_highest 
FROM receiverdata r INNER JOIN bonddata b 
ON r.Unique_key = b.unique_key
GROUP BY 1 ORDER BY 2 DESC LIMIT 1,1;  

-- 16. In which city were the greatest number of bonds purchased?
WITH MOST AS (
SELECT city, COUNT(unique_key) AS counting 
FROM donordata d INNER JOIN bankdata b 
ON b.branchCodeNo = d.PayBranchCode GROUP BY 1
) 
SELECT city, counting FROM MOST 
WHERE counting = (SELECT MAX(counting) FROM MOST);

-- 17. In which city was the highest amount spent on electoral bonds?
WITH highest AS(
SELECT ba.city ,SUM(b.denomination) AS amount_spent 
FROM donordata d INNER JOIN bonddata b 
ON d.Unique_key = b.unique_key
INNER JOIN bankdata ba 
ON d.PayBranchCode = ba.branchCodeNo
GROUP BY 1
)
SELECT city FROM highest 
WHERE amount_spent = (SELECT MAX(amount_spent) FROM highest);

-- 18. In which city were the least number of bonds purchased?
WITH LEAST AS (
SELECT city, COUNT(unique_key) AS counting 
FROM donordata d INNER JOIN bankdata b 
ON b.branchCodeNo = d.PayBranchCode GROUP BY 1
) 
SELECT city, COUNTING FROM LEAST 
WHERE counting = (SELECT MIN(counting) FROM LEAST);

-- 19. In which city were the greatest number of bonds enchased?
WITH enchased AS (
SELECT city, COUNT (unique_key) AS counting 
FROM receiverdata r INNER JOIN bankdata b 
ON b.branchCodeNo = r.PayBranchCode GROUP BY 1 order by 2 desc
) 
SELECT city, COUNTING FROM enchased 
WHERE counting = (SELECT MAX(counting) FROM enchased);

-- 20. In which city were the least number of bonds enchased?
WITH enchased AS (
SELECT city, COUNT(unique_key) AS counting 
FROM receiverdata r INNER JOIN bankdata b 
ON b.branchCodeNo = r.PayBranchCode 
GROUP BY 1 
ORDER BY 2 DESC
) 
SELECT city, COUNTING FROM enchased 
WHERE counting = (SELECT MIN(counting) FROM enchased);

-- 21. List the branches where no electoral bonds were bought. If none - mention it as null.
WITH _none AS (
SELECT city, COUNT(unique_key) AS counting 
FROM donordata d RIGHT JOIN bankdata b 
ON b.branchCodeNo = d.PayBranchCode 
GROUP BY 1
) 
SELECT city, counting FROM _none
WHERE counting = (SELECT MIN(counting) FROM _none);

-- 22. Break down how much money is spent on electoral bonds for each year.
SELECT YEAR(PurchaseDate) AS Year, SUM(denomination) AS total_spent_on_bonds
FROM donordata d 
INNER JOIN bonddata b
ON b.unique_key = d.Unique_key 
GROUP BY 1 ORDER BY 1; 

-- 23. Break down how much money is spent on electoral bonds for each year and provide the year and the amount. 
	-- Provide values for the highest and least year and amount.
WITH money_spent AS (
 SELECT YEAR(PurchaseDate) AS Year, SUM(denomination) AS total_spent_on_bonds
FROM donordata d 
INNER JOIN bonddata b
ON b.unique_key = d.Unique_key 
GROUP BY 1 ORDER BY 1 
)
SELECT Year, total_spent_on_bonds FROM money_spent 
WHERE total_spent_on_bonds = (SELECT MAX(total_spent_on_bonds) FROM MONEY_SPENT) 
OR total_spent_on_bonds = (SELECT MIN(total_spent_on_bonds) FROM MONEY_SPENT);
    
-- 24. Find out how many donors bought the bonds but did not donate to any political party?
SELECT COUNT(DISTINCT d.purchaser) AS num_donors
FROM donordata d LEFT JOIN receiverdata r
ON d.Unique_key = r.Unique_key 
WHERE r.unique_key IS NULL;

-- 25. Find out the money that could have gone to the PM Office, assuming the above question assumption (Domain Knowledge).
SELECT SUM(b.denomination) AS SUM_MONEY
FROM donordata d
LEFT JOIN bonddata b ON d.Unique_key = b.unique_key
LEFT JOIN receiverdata r ON d.Unique_key = r.Unique_key
WHERE r.Unique_key IS NULL;    
    
-- 26. Find out how many bonds don't have donors associated with them.
SELECT COUNT(DISTINCT r.unique_key) AS num_donors
FROM donordata d RIGHT JOIN receiverdata r
ON d.Unique_key = r.Unique_key 
WHERE d.Unique_key IS NULL;

-- 27. Find the employee ID who issued the highest number of bonds.
WITH ISSUED AS ( 
SELECT PayTeller, COUNT(*) AS bond_count
FROM donordata
GROUP BY PayTeller
 )
SELECT PayTeller, bond_count FROM ISSUED 
WHERE bond_count = (SELECT MAX(bond_count) FROM ISSUED);

SELECT PayTeller, COUNT(*) AS bond_count
FROM donordata
GROUP BY PayTeller
ORDER BY bond_count DESC
LIMIT 1;

-- 28. Find the employee ID who issued the least number of bonds.
WITH LEAST_NUM AS ( 
SELECT PayTeller, COUNT(*) AS bond_count,
RANK() OVER (ORDER BY COUNT(*) ASC) AS rn 
FROM donordata GROUP BY PayTeller 
)
SELECT PayTeller, bond_count FROM LEAST_NUM WHERE rn = 1; 

-- 29. Find the employee ID who assisted in redeeming or enchasing bonds the most.
WITH enchasing AS (
 SELECT PayTeller, COUNT(*) AS bond_count
FROM receiverdata
GROUP BY PayTeller
 )
SELECT PayTeller, bond_count FROM enchasing 
WHERE bond_count = (SELECT MAX(bond_count) FROM enchasing);

SELECT PayTeller, COUNT(*) AS bond_count
FROM receiverdata
GROUP BY PayTeller
ORDER BY bond_count DESC
LIMIT 1;

-- 30. Find the employee ID who assisted in redeeming or enchasing bonds the least
WITH LEAST_enchasing AS ( 
SELECT PayTeller, COUNT(*) AS bond_count,
RANK () OVER (ORDER BY COUNT(*) ASC) AS rn 
FROM receiverdata GROUP BY PayTeller
 )
SELECT PayTeller, bond_count FROM LEAST_enchasing WHERE rn = 1; 

-- 31. How many bonds are created?
SELECT COUNT(unique_key) AS Bonds_created FROM bonddata;

-- 32. Find the count of Unique Denominations provided by SBI?
SELECT COUNT(DISTINCT Denomination) AS count_ FROM bonddata ;

-- 33. List all the unique denominations that are available?
SELECT DISTINCT Denomination AS Unique_values FROM bonddata ORDER BY 1;

-- 34. Total money received by the bank for selling bonds
SELECT SUM(Denomination) AS money_receiverd FROM bonddata b
INNER JOIN donordata d
ON b.unique_key = d.Unique_key; 

-- 35. Find the count of bonds for each denomination that are created.
SELECT DISTINCT Denomination, COUNT(*) AS Bond_counts 
FROM bonddata GROUP BY 1 ORDER BY 1;

-- 36. Find the count and Amount or Valuation of electoral bonds for each denomination.
SELECT DISTINCT Denomination, SUM(Denomination) AS Valuation, COUNT(*) AS Total
FROM bonddata GROUP BY 1 ORDER BY 1;

-- 37. Number of unique bank branches where we can buy electoral bond?
SELECT COUNT(DISTINCT branchCodeNo) AS Total_branches FROM bankdata;

-- 38. How many companies bought electoral bonds?
SELECT COUNT(DISTINCT Purchaser) AS unique_companies FROM donordata;

-- 39. How many companies made political donations?
SELECT COUNT(DISTINCT Purchaser) AS unique_companies 
FROM donordata d INNER JOIN receiverdata r
ON d.Unique_key = r.Unique_key;

-- 40. How many parties received donations?
SELECT COUNT(DISTINCT PartyName) AS Unique_Parties FROM receiverdata;

-- 41. List all the political parties that received donations
SELECT DISTINCT PartyName FROM receiverdata;

-- 42. What is the average amount that each political party received?
SELECT DISTINCT PartyName, AVG(Denomination) 
FROM receiverdata r INNER JOIN bonddata b
ON b.unique_key = r.Unique_key GROUP BY 1;

-- 43. What is the average bond value produced by bank?
SELECT AVG(Denomination) AS Avg_value FROM bonddata; 

-- 44. List the political parties which have enchased bonds in different cities?
WITH parties_enchased as (
SELECT partyname, city, COUNT(b.unique_key)  
FROM receiverdata r JOIN bonddata b
ON r.Unique_key= b.unique_key
JOIN bankdata bb
ON b.unique_key = r.Unique_key
GROUP BY 1,2 ORDER BY partyname
)
SELECT DISTINCT partyname FROM parties_enchased;

-- 45. List the political parties which have enchased bonds in different cities and 
    -- list the cities in which the bonds have enchased as well?
SELECT DISTINCT partyname, city, COUNT(b.unique_key) 
FROM receiverdata r
LEFT JOIN bonddata b
ON r.Unique_key = b.unique_key
LEFT JOIN bankdata bb
ON bb.branchCodeNo = r.PayBranchCode
GROUP BY 1,2;

