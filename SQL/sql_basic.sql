---

SELECT COUNT(*)
FROM company
WHERE status = 'closed';

---

SELECT funding_total
FROM company
WHERE category_code = 'news'
  AND country_code ='USA'
ORDER BY funding_total DESC;

---

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
  AND EXTRACT(YEAR FROM acquired_at) BETWEEN 2011 AND 2013;

---

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

---

SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
  AND last_name LIKE 'K%';

---

SELECT country_code,
       SUM(funding_total) 
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC;

---

SELECT funded_at,
       MIN(raised_amount),
       MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) != 0
   AND MIN(raised_amount) != MAX(raised_amount);

---

SELECT *,
       CASE
           WHEN invested_companies >= 100 THEN 'high_activity'
           WHEN invested_companies BETWEEN 20 AND 99 THEN 'middle_activity'
           WHEN invested_companies < 20 THEN 'low_activity'
        END
FROM fund;

---

SELECT
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds)) AS avg
FROM fund
GROUP BY activity
ORDER BY avg;

---

SELECT country_code,
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM founded_at) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC, country_code
LIMIT 10;

---

SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people AS p
LEFT JOIN education AS e ON p.id = e.person_id;

---

SELECT c.name,
       COUNT(DISTINCT e.instituition)
FROM education AS e
INNER JOIN people AS p ON e.person_id = p.id
INNER JOIN company AS c ON p.company_id = c.id
GROUP BY c.name
ORDER BY COUNT(DISTINCT e.instituition) DESC
LIMIT 5;

---

SELECT c.name
FROM company AS c
LEFT JOIN funding_round AS f ON c.id = f.company_id
WHERE c.status = 'closed'
  AND f.is_first_round = 1 
  AND f.is_last_round = 1
GROUP BY c.name;

---

SELECT p.id
FROM company AS c
LEFT JOIN people AS p ON c.id = p.company_id
WHERE p.company_id IN (SELECT c.id
                 FROM company AS c
                 LEFT JOIN funding_round AS f ON c.id = f.company_id
                 WHERE c.status = 'closed'
                   AND f.is_first_round = 1 
                   AND f.is_last_round = 1);

---

SELECT DISTINCT person_id,
       instituition
FROM education 
WHERE person_id IN (SELECT p.id
                    FROM company AS c
                    LEFT JOIN people AS p ON c.id = p.company_id
                    WHERE p.company_id IN (SELECT c.id
                                     FROM company AS c
                                     LEFT JOIN funding_round AS f ON c.id = f.company_id
                                     WHERE c.status = 'closed'
                                       AND f.is_first_round = 1 
                                       AND f.is_last_round = 1));

---

SELECT person_id,
       COUNT(instituition)
FROM education 
WHERE person_id IN (SELECT p.id
                    FROM company AS c
                    LEFT JOIN people AS p ON c.id = p.company_id
                    WHERE p.company_id IN (SELECT c.id
                                     FROM company AS c
                                     LEFT JOIN funding_round AS f ON c.id = f.company_id
                                     WHERE c.status = 'closed'
                                       AND f.is_first_round = 1 
                                       AND f.is_last_round = 1))
GROUP BY person_id;

---

SELECT AVG(n.count)
FROM (SELECT person_id,
       COUNT(instituition)
        FROM education 
        WHERE person_id IN (SELECT p.id
                            FROM company AS c
                            LEFT JOIN people AS p ON c.id = p.company_id
                            WHERE p.company_id IN (SELECT c.id
                                             FROM company AS c
                                             LEFT JOIN funding_round AS f ON c.id = f.company_id
                                             WHERE c.status = 'closed'
                                               AND f.is_first_round = 1 
                                               AND f.is_last_round = 1))
        GROUP BY person_id) AS n;

---

SELECT AVG(n.count)
FROM (SELECT person_id,
       COUNT(instituition)
        FROM education 
        WHERE person_id IN (SELECT p.id
                            FROM company AS c
                            LEFT JOIN people AS p ON c.id = p.company_id
                            WHERE c.name = 'Facebook')
        GROUP BY person_id) AS n

---

SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM investment AS i
LEFT JOIN company AS c ON i.company_id = c.id
LEFT JOIN fund AS f ON i.fund_id = f.id
LEFT JOIN funding_round AS fr ON i.funding_round_id = fr.id
WHERE c.milestones > 6
  AND EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2012 AND 2013;

---

WITH
bought AS (SELECT a.id,
                  c.name AS nepokupatel,
                  c.funding_total
           FROM acquisition AS a
           LEFT JOIN company AS c ON a.acquired_company_id = c.id),
buying AS (SELECT a.id,
                  c.name AS pokupatel,
                  a.price_amount
           FROM acquisition AS a
           LEFT JOIN company AS c ON a.acquiring_company_id = c.id)
           
SELECT buying.pokupatel,
       buying.price_amount,
       bought.nepokupatel,
       bought.funding_total,
       ROUND(buying.price_amount/bought.funding_total)
FROM buying
LEFT JOIN bought ON buying.id = bought.id
WHERE buying.price_amount != 0
  AND bought.funding_total != 0
ORDER BY buying.price_amount DESC, bought.nepokupatel
LIMIT 10;

---

SELECT c.name,
       EXTRACT(MONTH FROM funded_at)
FROM company AS c
LEFT JOIN funding_round AS fr ON c.id = fr.company_id
WHERE c.category_code = 'social'
  AND EXTRACT(YEAR FROM funded_at) BETWEEN 2010 AND 2013
  AND fr.raised_amount != 0;

---

WITH
acq AS (SELECT EXTRACT(MONTH FROM acquired_at),
       COUNT(DISTINCT id),
       SUM(price_amount)
FROM acquisition
WHERE EXTRACT(YEAR FROM acquired_at) BETWEEN 2010 AND 2013
GROUP BY EXTRACT(MONTH FROM acquired_at)),

us AS (SELECT COUNT(DISTINCT f.name) AS names,
              EXTRACT(MONTH FROM funded_at)
FROM fund AS f
LEFT JOIN investment AS i ON f.id = i.fund_id
LEFT JOIN funding_round AS fr ON i.funding_round_id = fr.id
WHERE EXTRACT(YEAR FROM funded_at) BETWEEN 2010 AND 2013
  AND f.country_code = 'USA'
GROUP BY EXTRACT(MONTH FROM funded_at))

SELECT us.date_part,
       us.names,
       acq.count,
       acq.sum
FROM us
LEFT JOIN acq ON us.date_part = acq.date_part;

---

WITH
     inv_2011 AS (SELECT country_code,
                         AVG(funding_total) AS avg1
                  FROM company
                  WHERE EXTRACT(YEAR FROM founded_at) = 2011
                  GROUP BY country_code),
     inv_2012 AS (SELECT country_code,
                         AVG(funding_total) AS avg2
                  FROM company
                  WHERE EXTRACT(YEAR FROM founded_at) = 2012
                  GROUP BY country_code),
     inv_2013 AS (SELECT country_code,
                         AVG(funding_total) AS avg3
                  FROM company
                  WHERE EXTRACT(YEAR FROM founded_at) = 2013
                  GROUP BY country_code)
                  
SELECT inv_2011.country_code,
       inv_2011.avg1,
       inv_2012.avg2,
       inv_2013.avg3
FROM inv_2011
INNER JOIN inv_2012 ON inv_2011.country_code = inv_2012.country_code
INNER JOIN inv_2013 ON inv_2011.country_code = inv_2013.country_code
ORDER BY inv_2011.avg1 DESC;
