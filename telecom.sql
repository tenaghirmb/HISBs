/*
电信数据处理
[医疗]
[机票]
*/


-- bulk insert
BULK INSERT splitfile1 FROM 'C:\data\lte\splitfile1.txt'  
  WITH (  
      FIELDTERMINATOR = '\t',  
      ROWTERMINATOR = '\n'  
  );  


-- batch bulk insert
declare @count int
declare @spath varchar(500)
set @count=5
while @count<=330
begin
	set @spath = '''C:\data\lte\splitFile' + cast(@count as varchar(50)) + '.txt'''
	exec('BULK INSERT lte FROM ' + @spath + 'WITH (FIELDTERMINATOR = ''\t'', ROWTERMINATOR = ''\n'')')
	set @count = @count + 1
end


-- 修改表结构
ALTER TABLE lte   
ADD urldomain varchar(500) null  
GO
ALTER TABLE lte   
ADD timestamp1 datetime null
GO
alter table lte 
alter column userid varchar(100) null
GO
alter table lte 
alter column timestamp varchar(50) null
GO


-- 变换unix时间戳、提取url的域名
update [lte]
set urldomain=LEFT(url,CHARINDEX('/',url)-1),
	timestamp1=DATEADD(S,CAST( SUBSTRING(timestamp,1,10) AS INT ) + 8 * 3600,'1970-01-01 00:00:00')
where url is not null and CHARINDEX('/',url)>1


-- [医疗]统计域名访问次数
SELECT h.url url
      ,COUNT(*) cnt
INTO [data].[dbo].[sitecount]
FROM [data].[dbo].[healthsites] h
INNER JOIN [data].[dbo].[vLte] v
ON h.url = v.url1
GROUP BY h.url
ORDER BY cnt DESC
GO
SELECT h.url url
      ,h.name name
      ,h.category category
      ,ISNULL(c.cnt, 0) cnt
FROM [data].[dbo].[healthsites] h
LEFT JOIN [data].[dbo].[sitecount] c
ON h.url = c.url
ORDER BY cnt DESC
GO


-- [机票]导出ceair和ctrip的访问记录
-- ceair
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'ceair' AS [website]
      ,[channel] =
      CASE url1
          WHEN 'mobile.ceair.com' THEN 'app'
          ELSE 'browser'
      END
INTO [data].[dbo].[airflight]
FROM [data].[dbo].[vLte]
WHERE url1 IN ('mobile.ceair.com', 'm.ceair.com', 'www.ceair.com')
GO
-- ctrip
INSERT INTO [data].[dbo].[airflight]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'ctrip' AS [website]
      ,[channel] =
      CASE
          WHEN agent LIKE '%okhttp%' THEN 'app'
          WHEN agent LIKE '%Dalvik%' THEN 'app'
          WHEN agent LIKE '%Darwin%' THEN 'app'
          WHEN agent LIKE '%Ctrip%' THEN 'app'
          ELSE 'browser'
      END
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%flight%ctrip%'
    OR url1='m.ctrip.com'
    OR url1 LIKE '%ctrip.com' AND url LIKE '%flight%' AND url1 NOT LIKE '%flight%' AND url1 <> 'm.ctrip.com'
GO


-- [机票]导出其他网站的访问记录
USE data
GO

ALTER TABLE airflight
ALTER COLUMN website VARCHAR(10) NULL
GO

ALTER TABLE airflight
ALTER COLUMN channel VARCHAR(10) NULL
GO

INSERT INTO [data].[dbo].[airflight]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,[website] =
      CASE
          WHEN url1 IN ('www.ly.com', 'm.ly.com') THEN 'ly'
          WHEN url1 IN ('m.tuniu.com', 'flight-api.tuniu.com') THEN 'tuniu'
          WHEN url1 = 'm.elong.com' THEN 'elong'
          WHEN url1 IN ('www.airchina.com.cn', 'm.airchina.com', 'm.airchina.com.cn') THEN 'airchina'
          WHEN url1 IN ('airport.csair.com', 'www.csair.com', 'm.csair.com', 'b2c.csair.com', 'wxapi.csair.com') THEN 'csair'
          WHEN url1 LIKE '%juneyaoair.com' THEN 'juneyaoair'
      END
      ,NULL AS [channel]
FROM [data].[dbo].[vLte]
WHERE url LIKE '%flight%'
    AND url1 IN ('www.ly.com', 'm.ly.com', 'm.tuniu.com', 'flight-api.tuniu.com', 'm.elong.com')
    OR url1 IN ('www.airchina.com.cn', 'm.airchina.com', 'm.airchina.com.cn', 'airport.csair.com', 'www.csair.com', 'm.csair.com', 'b2c.csair.com', 'wxapi.csair.com')
    OR url1 LIKE '%juneyaoair.com'
GO


-- [机票]T1-T4
-- T1
SELECT [userid]
      ,LEFT(date, 8) AS [date]
      ,[website]
      ,[channel]
      ,COUNT(url) AS [request times]
FROM [data].[dbo].[airflight]
GROUP BY userid, LEFT(date, 8), website, channel
HAVING website IN ('ctrip', 'ceair')
ORDER BY userid, LEFT(date, 8), website, channel
GO

-- T2
SELECT [userid]
      ,[website]
      ,MIN(LEFT(date, 8)) AS [date]
FROM [data].[dbo].[airflight]
GROUP BY userid, website, channel
HAVING channel='app' AND website IN ('ctrip', 'ceair')
ORDER BY userid, website
GO

-- T3
-- 创建临时表
IF OBJECT_ID('tempdb..##T2') IS NOT NULL
    DROP TABLE ##T2
GO
SELECT [userid]
      ,[website]
      ,MIN(timestamp) AS [timestamp]
INTO ##T2
FROM [data].[dbo].[airflight]
GROUP BY userid, website, channel
HAVING channel='app' AND website IN ('ctrip', 'ceair')
ORDER BY userid, website
GO
IF OBJECT_ID('tempdb..##tmp') IS NOT NULL
    DROP TABLE ##tmp
GO
SELECT [userid]
      ,[timestamp]
      ,[website]
      ,[timestamp1]
INTO ##tmp
FROM [data].[dbo].[airflight]
GO
-- before
IF OBJECT_ID('tempdb..##T3C1') IS NOT NULL
    DROP TABLE ##T3C1
GO
SELECT a.userid
      ,DATEPART(month, b.timestamp1) AS [month]
      ,COUNT(DISTINCT b.website) AS [before]
INTO ##T3C1
FROM ##T2 a
LEFT JOIN ##tmp b
ON a.userid = b.userid
WHERE a.timestamp >= b.timestamp AND a.website='ctrip'
GROUP BY a.userid, DATEPART(month, b.timestamp1)
ORDER BY a.userid, DATEPART(month, b.timestamp1)
GO
SELECT userid
      ,AVG(before) AS [before_avg]
INTO ##T3C1A
FROM ##T3C1
GROUP BY userid
ORDER BY userid
GO

-- after
IF OBJECT_ID('tempdb..##T3C2') IS NOT NULL
    DROP TABLE ##T3C2
GO
SELECT a.userid
      ,DATEPART(month, b.timestamp1) AS [month]
      ,COUNT(DISTINCT b.website) AS [after]
INTO ##T3C2
FROM ##T2 a
LEFT JOIN ##tmp b
ON a.userid = b.userid
WHERE a.timestamp < b.timestamp AND a.website='ctrip'
GROUP BY a.userid, DATEPART(month, b.timestamp1)
ORDER BY a.userid, DATEPART(month, b.timestamp1)
GO
SELECT userid
      ,AVG(after) AS [after_avg]
INTO ##T3C2A
FROM ##T3C2
GROUP BY userid
ORDER BY userid
GO

-- merge
SELECT ISNULL(a.userid, b.userid) AS userid
      ,a.before_avg
      ,b.after_avg
INTO ##T3
FROM ##T3C1A a
FULL OUTER JOIN ##T3C2A b
ON a.userid = b.userid
ORDER BY userid
GO

SELECT COUNT(userid)
FROM ##T3
WHERE before_avg < after_avg
GO

-- T4
-- before
IF OBJECT_ID('tempdb..##T4C1') IS NOT NULL
    DROP TABLE ##T4C1
GO
SELECT a.userid
      ,DATEPART(month, b.timestamp1) AS [month]
      ,COUNT(DISTINCT b.website) AS [before]
INTO ##T4C1
FROM ##T2 a
LEFT JOIN ##tmp b
ON a.userid = b.userid
WHERE a.timestamp >= b.timestamp AND a.website='ceair'
GROUP BY a.userid, DATEPART(month, b.timestamp1)
ORDER BY a.userid, DATEPART(month, b.timestamp1)
GO
SELECT userid
      ,AVG(before) AS [before_avg]
INTO ##T4C1A
FROM ##T4C1
GROUP BY userid
ORDER BY userid
GO

-- after
IF OBJECT_ID('tempdb..##T4C2') IS NOT NULL
    DROP TABLE ##T4C2
GO
SELECT a.userid
      ,DATEPART(month, b.timestamp1) AS [month]
      ,COUNT(DISTINCT b.website) AS [after]
INTO ##T4C2
FROM ##T2 a
LEFT JOIN ##tmp b
ON a.userid = b.userid
WHERE a.timestamp < b.timestamp AND a.website='ceair'
GROUP BY a.userid, DATEPART(month, b.timestamp1)
ORDER BY a.userid, DATEPART(month, b.timestamp1)
GO
SELECT userid
      ,AVG(after) AS [after_avg]
INTO ##T4C2A
FROM ##T4C2
GROUP BY userid
ORDER BY userid
GO

-- merge
SELECT ISNULL(a.userid, b.userid) AS userid
      ,a.before_avg
      ,b.after_avg
INTO ##T4
FROM ##T4C1A a
FULL OUTER JOIN ##T4C2A b
ON a.userid = b.userid
ORDER BY userid
GO


-- [医疗]导出健康相关记录
-- haodf
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'haodf' AS [website]
INTO [data].[dbo].[health_records]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.haodf.%'
GO

USE data
GO

ALTER TABLE health_records
ALTER COLUMN website VARCHAR(10) NULL
GO

-- cndzys
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'cndzys' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.cndzys.%'
GO

-- boohee
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'boohee' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.boohee.%'
GO

-- guahao
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'guahao' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.guahao.%'
GO

-- 39net
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'39net' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.39.net'
GO

-- 120ask
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'120ask' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.120.net' OR url1 LIKE '%.120ask%'
GO

-- xywy
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'xywy' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.xywy.%'
GO

-- 360kad
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'360kad' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.360kad.%'
GO

-- chunyuyisheng
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'chunyu' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.chunyuyisheng.%'
GO

-- jianke
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'jianke' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.jianke.%'
GO

-- soyoung
INSERT INTO [data].[dbo].[health_records]
SELECT [userid]
      ,[timestamp]
      ,[url]
      ,[agent]
      ,[ref]
      ,[date]
      ,[slashindex]
      ,[url1]
      ,[timestamp1]
      ,'soyoung' AS [website]
FROM [data].[dbo].[vLte]
WHERE url1 LIKE '%.soyoung.%'
GO


-- [医疗]Seasoning Trends
SELECT DATEPART(quarter,timestamp1) AS [quarter]
      ,[website]
      ,COUNT(url) AS [Number of visits]
      ,COUNT(DISTINCT userid) AS [Unique Visitors]
FROM [data].[dbo].[health_records]
GROUP BY DATEPART(quarter,timestamp1), website
ORDER BY quarter, website
GO


-- [医疗]Week Trends
SET DATEFIRST 1;
SELECT DATEPART(weekday,timestamp1) AS [weekday]
      ,[website]
      ,COUNT(url) AS [Number of visits]
      ,COUNT(DISTINCT userid) AS [Unique Visitors]
FROM [data].[dbo].[health_records]
GROUP BY DATEPART(weekday,timestamp1), website
ORDER BY weekday, website
GO


-- [医疗]Time Trends
SELECT DATEPART(hour,timestamp1) AS [hour]
      ,[website]
      ,COUNT(url) AS [Number of visits]
      ,COUNT(DISTINCT userid) AS [Unique Visitors]
FROM [data].[dbo].[health_records]
GROUP BY DATEPART(hour,timestamp1), website
ORDER BY hour, website
GO


-- [机票]Intensity of use
SELECT [userid]
      ,LEFT(date, 8) AS [date]
      ,[website]
      ,[channel]
      ,COUNT(url) AS [request_times]
INTO ##t1
FROM [data].[dbo].[airflight]
GROUP BY userid, LEFT(date, 8), website, channel
HAVING website IN ('ctrip', 'ceair')
ORDER BY userid, LEFT(date, 8), website, channel
GO

SELECT [userid]
      ,[website]
      ,MIN(LEFT(date, 8)) AS [date]
INTO ##t2
FROM [data].[dbo].[airflight]
GROUP BY userid, website, channel
HAVING channel='app' AND website IN ('ctrip', 'ceair')
ORDER BY userid, website
GO

-- ctrip_before
SELECT a.userid
      ,a.date
      ,a.website
      ,a.channel
      ,a.request_times
      ,b.date AS ctrip_initial
INTO #ctrip_before
FROM ##t1 a
RIGHT JOIN ##t2 b
ON a.userid = b.userid
WHERE b.website='ctrip' and a.date < b.date
ORDER BY a.userid, a.date, a.website, a.channel
GO
SELECT userid
      ,channel
      ,AVG(request_times) AS Intensity
FROM #ctrip_before
GROUP BY userid, channel
ORDER BY userid, channel
GO

-- ctrip_after
SELECT a.userid
      ,a.date
      ,a.website
      ,a.channel
      ,a.request_times
      ,b.date AS ctrip_initial
INTO #ctrip_after
FROM ##t1 a
RIGHT JOIN ##t2 b
ON a.userid = b.userid
WHERE b.website='ctrip' and a.date >= b.date
ORDER BY a.userid, a.date, a.website, a.channel
GO
SELECT userid
      ,channel
      ,AVG(request_times) AS Intensity
FROM #ctrip_after
GROUP BY userid, channel
ORDER BY userid, channel
GO

-- ceair_before
SELECT a.userid
      ,a.date
      ,a.website
      ,a.channel
      ,a.request_times
      ,b.date AS ceair_initial
INTO #ceair_before
FROM ##t1 a
RIGHT JOIN ##t2 b
ON a.userid = b.userid
WHERE b.website='ceair' and a.date < b.date
ORDER BY a.userid, a.date, a.website, a.channel
GO
SELECT userid
      ,channel
      ,AVG(request_times) AS Intensity
FROM #ceair_before
GROUP BY userid, channel
ORDER BY userid, channel
GO

-- ceair_after
SELECT a.userid
      ,a.date
      ,a.website
      ,a.channel
      ,a.request_times
      ,b.date AS ctrip_initial
INTO #ceair_after
FROM ##t1 a
RIGHT JOIN ##t2 b
ON a.userid = b.userid
WHERE b.website='ceair' and a.date >= b.date
ORDER BY a.userid, a.date, a.website, a.channel
GO
SELECT userid
      ,channel
      ,AVG(request_times) AS Intensity
FROM #ceair_after
GROUP BY userid, channel
ORDER BY userid, channel
GO


-- [医疗]Number of visits & Unique visitors
SELECT website
      ,COUNT(url) AS nv
      ,COUNT(DISTINCT userid) AS uv
FROM [data].[dbo].[health_records]
GROUP BY website
ORDER BY nv DESC
GO


-- [医疗]Search penetration: unique visitors
SELECT s.category
      ,COUNT(DISTINCT userid) AS uv
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[healthsites] s
ON r.website = s.abbreviation
GROUP BY s.category
ORDER BY s.category DESC
GO

-- [医疗]Distribution of search effort
SELECT s.category
      ,COUNT(r.url) AS nv
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[healthsites] s
ON r.website = s.abbreviation
GROUP BY s.category
ORDER BY s.category DESC
GO






