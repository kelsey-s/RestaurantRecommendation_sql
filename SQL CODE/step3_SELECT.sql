-- 1.What are restaurants in each type(cuisine) can be recommended to customers who have a low budget($)?
SELECT r.restAvgPrice, u.cuiName, r.restName
FROM [CPDelicacy.Restaurant] r, [CPDelicacy.Offer] o, [CPDelicacy.Cuisine] u
WHERE r.restId = o.restId AND o.cuiId = u.cuiId AND r.restAvgPrice in('$')
GROUP BY  u.cuiName, r.restName

-- 2.What are the average review rate for each restaurant for each app and all app?
SELECT COALESCE(r.restName,'All restaurant') AS 'Restaurants', 
	COALESCE(a.appName,'All Apps') AS 'Apps', AVG(CONVERT(float,g.restRate)) AS 'AverageRate'
FROM [CPDelicacy.Restaurant] r, [CPDelicacy.Register] g, [CPDelicacy.App] a
WHERE r.restId = g.restId AND a.appId=g.appId
GROUP BY ROLLUP (r.restName, a.appName)

-- 3.What choices do a customer have in terms of choosing a certain cuisine?
SELECT u.cuiName, r.restName
FROM [CPDelicacy.Cuisine] u, [CPDelicacy.Restaurant] r, [CPDelicacy.Offer] o
WHERE u.cuiId = o.cuiId AND r.restId = o.restId
ORDER BY u.cuiName

--4.For a vegetarian customer who forgets to bring any cash, which restaurants can he go? 
SELECT r.restName, r.restVeggie, p.payName
FROM [CPDelicacy.Restaurant] r, [CPdelicacy.Accept] t, [CPDelicacy.Payment] p
WHERE r.restId = t.restId AND t.payId = p.payId 
	AND r.restVeggie = 'Yes' AND p.payName <> 'cashPayment'

-- 5.What restaurants are recommended to a veggie customer who drives to have lunch 
-- in a chinese restaurant and consider restaurant rate first and then price? 
SELECT r.*, g.AveRate
FROM [CPDelicacy.Restaurant] r, [CPDelicacy.Offer] o, [CPDelicacy.Cuisine] u,
	 (SELECT restId, AVG(Convert(float,restRate)) AS 'AveRate'
	  FROM [CPDelicacy.Register]
	  GROUP BY restId) g
WHERE r.restId=o.restId AND o.cuiId = u.cuiId AND r.restId=g.restId
 AND r.restVeggie='Yes' AND u.cuiName='Chinese' AND r.restParking = 'Yes'
ORDER BY g.AveRate DESC

--6.For each cuisine, what are the number of restaurants and the corresponding average review rate?
SELECT u.cuiName,  COUNT(r.restId) AS 'Number of Restaurants', AVG(v.AveRate) AS 'AveReviewRate'
FROM [CPDelicacy.Restaurant] r, [CPDelicacy.Offer] o, [CPDelicacy.Cuisine] u,
 (SELECT restId, AVG(Convert(float,rvwRate)) AS 'AveRate'
  FROM [CPDelicacy.Review]
  GROUP BY restId) v
WHERE r.restId=o.restID AND o.cuiId = u.cuiId AND r.restId=v.restId
GROUP BY u.cuiName

--7.For a potential restaurant owner looking at Japanese cuisine, what are otherJapanese restaurants name?

SELECT r.restName
FROM [CPDelicacy.Restaurant] r, [CPDelicacy.Cuisine] u, [CPDelicacy.Offer] o 
WHERE r.restId = o.restId AND u.cuiId = o.cuiId AND cuiName IN ('Sushi','Japanese','Teppanyaki','Ramen') 