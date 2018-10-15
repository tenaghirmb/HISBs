/*
电信数据处理
[医疗]
SQL Server
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
SELECT DATEPART(quarter,r.timestamp1) AS [quarter]
      ,s.category AS category
      ,COUNT(r.url) AS [Number of visits]
      ,COUNT(DISTINCT r.userid) AS [Unique Visitors]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[healthsites] s
ON r.website = s.abbreviation
GROUP BY DATEPART(quarter,r.timestamp1), s.category
ORDER BY quarter, category
GO


-- [医疗]Week Trends
SET DATEFIRST 1;
SELECT DATEPART(weekday,r.timestamp1) AS [weekday]
      ,s.category AS category
      ,COUNT(r.url) AS [Number of visits]
      ,COUNT(DISTINCT r.userid) AS [Unique Visitors]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[healthsites] s
ON r.website = s.abbreviation
GROUP BY DATEPART(weekday,r.timestamp1), s.category
ORDER BY weekday, category
GO


-- [医疗]Time Trends
SELECT DATEPART(hour,r.timestamp1) AS [hour]
      ,s.category AS category
      ,COUNT(r.url) AS [Number of visits]
      ,COUNT(DISTINCT r.userid) AS [Unique Visitors]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[healthsites] s
ON r.website = s.abbreviation
GROUP BY DATEPART(hour,r.timestamp1), s.category
ORDER BY hour, category
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


-- [医疗]Diversity
IF OBJECT_ID('tempdb..#Diversity') IS NOT NULL
    DROP TABLE #Diversity
GO
IF OBJECT_ID('tempdb..#csavg') IS NOT NULL
    DROP TABLE #csavg
GO
SELECT userid
      ,DATEPART(quarter, timestamp1) AS [quarter]
      ,COUNT(DISTINCT website) AS cs
INTO #Diversity
FROM [data].[dbo].[health_records]
GROUP BY userid, DATEPART(quarter, timestamp1)
ORDER BY userid, DATEPART(quarter, timestamp1)
GO
SELECT userid
      ,AVG(cs) AS cs_avg
INTO #csavg
FROM #Diversity
GROUP BY userid
ORDER BY userid
GO
SELECT cs_avg AS cs
      ,COUNT(DISTINCT userid) AS cnt
      ,CONVERT(DECIMAL(4,4), COUNT(DISTINCT userid)/CONVERT(DECIMAL(5,2), (SELECT COUNT(DISTINCT userid) FROM #csavg))) AS pct
FROM #csavg
GROUP BY cs_avg
ORDER BY cs
GO


-- [医疗]Consideration Set each Session
IF OBJECT_ID('tempdb..#Diversity') IS NOT NULL
    DROP TABLE #Diversity
GO
SELECT userid
      ,date
      ,COUNT(DISTINCT website) AS cs
INTO #Diversity
FROM [data].[dbo].[health_records]
GROUP BY userid, date
ORDER BY userid, date
GO
SELECT cs
      ,COUNT(cs) AS sessions
      ,CONVERT(DECIMAL(4,4), COUNT(cs)/CONVERT(DECIMAL(6,2), (SELECT COUNT(cs) FROM #Diversity))) AS pct
FROM #Diversity
GROUP BY cs
ORDER BY cs
GO


-- [医疗]Number of Visits each Session
IF OBJECT_ID('tempdb..#Intensity') IS NOT NULL
    DROP TABLE #Intensity
GO
SELECT userid
      ,date
      ,COUNT(url) AS Intensity
INTO #Intensity
FROM [data].[dbo].[health_records]
GROUP BY userid, date
ORDER BY userid, date
GO
SELECT Intensity
      ,COUNT(Intensity) AS sessions
FROM #Intensity
GROUP BY Intensity
ORDER BY Intensity
GO


-- [医疗]Loyalty
SELECT r.userid
      ,h.category
      ,r.website
      ,COUNT(r.url) AS [Visit Numbers]
      ,COUNT(DISTINCT r.date) AS [Visit Days]
      ,DATEDIFF(day ,MAX(r.date), '2017-08-31') AS [Last Visit]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[healthsites] h
ON r.website = h.abbreviation
GROUP BY r.userid, h.category, r.website
ORDER BY r.userid, h.category, r.website
GO


-- [医疗]Cross-browsing
IF OBJECT_ID('tempdb..##c1') IS NOT NULL
    DROP TABLE ##c1
GO
SELECT r.userid
      ,h.category
      ,COUNT(r.url) AS [Number of Visits]
INTO ##c1
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[healthsites] h
ON r.website = h.abbreviation
GROUP BY r.userid, h.category
ORDER BY r.userid, h.category
GO
SELECT category
      ,COUNT(DISTINCT userid) AS [Unique Users]
      ,SUM([Number of Visits]) AS [Number of Visits]
FROM ##c1
GROUP BY category
ORDER BY category
GO

CREATE TABLE data.dbo.CrossBrowsing  
(  
    userid varchar(100) PRIMARY KEY
    ,medical int  NULL  
    ,lifestyle int NULL  
    ,epharmacy int NULL  
);

INSERT INTO data.dbo.CrossBrowsing (userid)
SELECT DISTINCT userid
FROM ##c1
GO
USE data
GO
UPDATE CrossBrowsing set CrossBrowsing.medical = ##c1.[Number of Visits]
FROM ##c1
WHERE CrossBrowsing.userid = ##c1.userid AND ##c1.category = 'Medical'
GO
UPDATE CrossBrowsing set CrossBrowsing.lifestyle = ##c1.[Number of Visits]
FROM ##c1
WHERE CrossBrowsing.userid = ##c1.userid AND ##c1.category = 'Lifestyle'
GO
UPDATE CrossBrowsing set CrossBrowsing.epharmacy = ##c1.[Number of Visits]
FROM ##c1
WHERE CrossBrowsing.userid = ##c1.userid AND ##c1.category = 'E-pharmacy'
GO

SELECT COUNT(lifestyle) ul
      ,SUM(lifestyle) vl
      ,COUNT(epharmacy) ue
      ,SUM(epharmacy) ve
FROM data.dbo.CrossBrowsing
WHERE medical IS NOT NULL
GO


-- [医疗]Create labels(Platform & Channel)
ALTER TABLE [data].[dbo].[health_records]
ADD platform varchar(20) null  
GO
ALTER TABLE [data].[dbo].[health_records]
ADD channel varchar(20) null
GO

-- platform
UPDATE [data].[dbo].[health_records]
SET platform =
    CASE
        WHEN agent LIKE '%Apache-HttpClient%' THEN 'android'
        WHEN agent LIKE '%Dalvik%' THEN 'android'
        WHEN agent LIKE '%Darwin%' THEN 'iphone'
        WHEN agent LIKE '%iPhone%' THEN 'iphone'
        WHEN agent LIKE '%android%' THEN 'android'
        WHEN agent LIKE '%Mozilla/% (i%' THEN 'iphone'
        WHEN agent LIKE '%Mozilla/% (L%' THEN 'android'
        WHEN agent LIKE '%okhttp%' THEN 'android'
        WHEN agent LIKE '%Xiaomi%' THEN 'android'
        WHEN agent LIKE '%Macintosh%' THEN 'iphone'
        WHEN agent LIKE '%Phoenix%' THEN 'android'
    END
GO

-- channel
UPDATE [data].[dbo].[health_records]
SET channel =
    CASE
        WHEN agent LIKE '%Apache-HttpClient%' THEN 'app'
        WHEN agent LIKE '%Phoenix%' THEN 'app'
        WHEN agent LIKE '%okhttp%' THEN 'app'
        WHEN agent LIKE '%Dalvik%' THEN 'app'
        WHEN agent LIKE '%Darwin%' THEN 'app'
        WHEN agent LIKE 'QQ%' THEN 'browser'
        WHEN agent LIKE 'Xiaomi%' THEN 'browser'
        WHEN agent LIKE '%app%' THEN 'app'
        WHEN agent = 'Android/Volley' THEN 'app'
        WHEN agent = 'Android/retrofit' THEN 'app'
        WHEN agent LIKE 'Mozilla%Linux%Version%' THEN 'app'
        WHEN agent LIKE 'Mozilla%Linux%' THEN 'browser'
        WHEN agent LIKE 'Mozilla%iPhone%Version%' THEN 'browser'
        WHEN agent LIKE 'Mozilla%iPhone%' THEN 'app'
    END
GO


-- [医疗]T-test
-- Number of Visits
SELECT userid
      ,platform
      ,COUNT(url) AS [Number of Visits]
FROM [data].[dbo].[health_records]
GROUP BY userid, platform
HAVING platform IS NOT NULL
ORDER BY userid, platform
GO

SELECT userid
      ,channel
      ,COUNT(url) AS [Number of Visits]
FROM [data].[dbo].[health_records]
GROUP BY userid, channel
HAVING channel IS NOT NULL
ORDER BY userid, channel
GO

SELECT r.userid
      ,u.gender
      ,COUNT(r.url) AS [Number of Visits]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, u.gender
HAVING u.gender IS NOT NULL
ORDER BY r.userid
GO

SELECT r.userid
      ,IIF(u.consumption>10000,'high','low') AS income
      ,COUNT(r.url) AS [Number of Visits]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, u.consumption
HAVING u.consumption IS NOT NULL
ORDER BY r.userid
GO

-- Intensity of Use
SELECT userid
      ,platform
      ,COUNT(url) AS [Use Intensity]
      ,date
FROM [data].[dbo].[health_records]
GROUP BY userid, date, platform
HAVING platform IS NOT NULL
ORDER BY userid, date, platform
GO

SELECT userid
      ,channel
      ,COUNT(url) AS [Use Intensity]
      ,date
FROM [data].[dbo].[health_records]
GROUP BY userid, date, channel
HAVING channel IS NOT NULL
ORDER BY userid, date, channel
GO

SELECT r.userid
      ,u.gender
      ,COUNT(r.url) AS [Use Intensity]
      ,r.date
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, r.date, u.gender
HAVING u.gender IS NOT NULL
ORDER BY r.userid, r.date
GO

SELECT r.userid
      ,IIF(u.consumption>10000,'high','low') AS income
      ,COUNT(r.url) AS [Use Intensity]
      ,r.date
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, r.date, u.consumption
HAVING u.consumption IS NOT NULL
ORDER BY r.userid, r.date
GO


-- [医疗]ANOVA
-- Number of Visits
SELECT r.userid
      ,r.channel
      ,IIF(u.consumption>10000,'high','low') AS income
      ,COUNT(r.url) AS [Number of Visits]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, r.channel, u.consumption
HAVING r.channel IS NOT NULL AND u.consumption IS NOT NULL
ORDER BY r.userid
GO

SELECT r.userid
      ,r.platform
      ,IIF(u.consumption>10000,'high','low') AS income
      ,COUNT(r.url) AS [Number of Visits]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, r.platform, u.consumption
HAVING r.platform IS NOT NULL AND u.consumption IS NOT NULL
ORDER BY r.userid
GO

SELECT r.userid
      ,u.gender
      ,IIF(u.consumption>10000,'high','low') AS income
      ,COUNT(r.url) AS [Number of Visits]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, u.gender, u.consumption
HAVING u.gender IS NOT NULL AND u.consumption IS NOT NULL
ORDER BY r.userid
GO

SELECT r.userid
      ,r.platform
      ,u.gender
      ,COUNT(r.url) AS [Number of Visits]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, r.platform, u.gender
HAVING r.platform IS NOT NULL AND u.gender IS NOT NULL
ORDER BY r.userid
GO

SELECT r.userid
      ,r.channel
      ,u.gender
      ,COUNT(r.url) AS [Number of Visits]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, r.channel, u.gender
HAVING r.channel IS NOT NULL AND u.gender IS NOT NULL
ORDER BY r.userid
GO

-- Intensity of Use
SELECT r.userid
      ,r.platform
      ,r.channel
      ,u.gender
      ,IIF(u.consumption>10000,'high','low') AS income
      ,COUNT(r.url) AS [Use Intensity]
FROM [data].[dbo].[health_records] r
JOIN [data].[dbo].[user] u
ON r.userid = u.userid
GROUP BY r.userid, r.date, r.platform, r.channel, u.gender, u.consumption
HAVING r.platform IS NOT NULL AND r.channel IS NOT NULL AND u.gender IS NOT NULL AND u.consumption IS NOT NULL
ORDER BY r.userid, r.date
GO


-- [医疗]fsQCA
IF OBJECT_ID('tempdb..##tmp') IS NOT NULL
    DROP TABLE ##tmp
GO
SELECT userid
      ,date
      ,platform
      ,channel
      ,COUNT(url) AS intensity
INTO ##tmp
FROM [data].[dbo].[health_records]
GROUP BY userid, date, platform, channel
HAVING platform IS NOT NULL AND channel IS NOT NULL
ORDER BY userid, date, platform, channel
GO
IF OBJECT_ID('tempdb..##j') IS NOT NULL
    DROP TABLE ##j
GO
SELECT userid
      ,platform
      ,channel
      ,AVG(intensity) AS intensity
INTO ##j
FROM ##tmp
GROUP BY userid, platform, channel
ORDER BY userid, platform, channel
GO
SELECT j.userid
      ,j.platform
      ,j.channel
      ,u.gender
      ,u.consumption AS income
      ,j.intensity
FROM ##j j
JOIN [data].[dbo].[user] u
ON u.userid = j.userid
GO