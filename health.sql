/*
电信数据处理
健康医疗
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


-- 新增列、修改列
ALTER TABLE lte   
ADD urldomain varchar(500) null  

ALTER TABLE lte   
ADD timestamp1 datetime null

alter table lte 
alter column userid varchar(100) null

alter table lte 
alter column timestamp varchar(50) null


-- 变换unix时间戳、提取url的域名
update [lte]
set urldomain=LEFT(url,CHARINDEX('/',url)-1),
	timestamp1=DATEADD(S,CAST( SUBSTRING(timestamp,1,10) AS INT ) + 8 * 3600,'1970-01-01 00:00:00')
where url is not null and CHARINDEX('/',url)>1


-- 统计域名访问次数
SELECT h.url url
      ,COUNT(*) cnt
  INTO [data].[dbo].[sitecount]
  FROM [data].[dbo].[healthsites] h
  INNER JOIN [data].[dbo].[vLte] v
  ON h.url = v.url1
  GROUP BY h.url
  ORDER BY cnt DESC

SELECT h.url url
      ,h.name name
      ,h.Category category
      ,isnull(c.cnt, 0) cnt
  FROM [data].[dbo].[healthsites] h
  LEFT JOIN [data].[dbo].[sitecount] c
  ON h.url = c.url
  ORDER BY cnt DESC

