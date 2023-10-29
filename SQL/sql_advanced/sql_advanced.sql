---

SELECT EXTRACT(DAY FROM creation_date::date) AS day,
       COUNT(id),
       SUM(COUNT(id)) OVER(ORDER BY EXTRACT(DAY FROM creation_date::date))
FROM stackoverflow.users
WHERE DATE_TRUNC('month', creation_date::date) = '2008-11-01'
GROUP BY day;

---

SELECT user_id,
       creation_date,
       views_count,
       SUM(views_count) OVER(PARTITION BY user_id ORDER BY creation_date)
FROM stackoverflow.posts
ORDER BY user_id, creation_date;

---

WITH main AS (
SELECT EXTRACT(MONTH FROM creation_date::date) AS mn,
       COUNT(id) AS cnt,
       LAG(COUNT(id)) OVER(ORDER BY EXTRACT(MONTH FROM creation_date::date)) AS prev_cnt
FROM stackoverflow.posts
WHERE EXTRACT(MONTH FROM creation_date::date) BETWEEN 9 AND 12
  AND EXTRACT(YEAR FROM creation_date::date) = 2008
GROUP BY mn)

SELECT mn,
       cnt,
       ROUND((cnt/prev_cnt::numeric - 1)*100, 2)
FROM main
WHERE mn BETWEEN 9 AND 12;

---

SELECT p.title,
       u.id,
       p.score,
       ROUND(AVG(score) OVER(PARTITION BY u.id))
FROM stackoverflow.users AS u
LEFT JOIN stackoverflow.posts AS p ON u.id = p.user_id
WHERE p.title IS NOT NULL
  AND p.score IS NOT NULL
  AND p.score != 0;

---

SELECT u.id,
       COUNT(b.id) AS cnt,
       DENSE_RANK() OVER(ORDER BY COUNT(b.id) DESC)
FROM stackoverflow.users AS u
LEFT JOIN stackoverflow.badges AS b ON u.id = b.user_id
WHERE b.creation_date::date BETWEEN '2008-11-15' AND '2008-12-15'
GROUP BY u.id
ORDER BY cnt DESC, u.id
LIMIT 10;

---

SELECT *,
       ROW_NUMBER() OVER(ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id ASC;
