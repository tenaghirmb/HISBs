USE hdf;

-- 医院等级
SELECT
	grade,
	COUNT(Id) cnt
FROM
	hospitalinfo_table
GROUP BY
	grade;

-- 医生职称
SELECT
	doctorProfession,
	COUNT(id) cnt
FROM
	doctor_info_resource
GROUP BY
	doctorProfession;

-- 医生重名情况
-- SELECT
-- 	doctorName,
-- 	COUNT(*) cnt
-- FROM
-- 	doctor_info_resource
-- GROUP BY
-- 	doctorName
-- ORDER BY
-- 	cnt DESC;

-- 创建医生评价指标表
CREATE TABLE
IF NOT EXISTS doctor_sort (
	doctorName VARCHAR (100),
	doctorProfession VARCHAR (100),
	hospital_grade VARCHAR (255),
	number_of_comments FLOAT,
	comment_score FLOAT
);

-- 评价数量和平均评论点赞数
INSERT INTO doctor_sort (
	doctorName,
	number_of_comments,
	comment_score
) SELECT
	doctorName,
	COUNT(*) noc,
	AVG(useful) cs
FROM
	data_doc_dis_topic_f_weight
GROUP BY
	doctorName;

-- 更新医生职称和医院等级
CREATE TEMPORARY TABLE doctor_status SELECT
	d.doctorName,
	d.doctorProfession,
	h.grade
FROM
	doctor_info_resource d
LEFT JOIN hospitalinfo_table h ON d.hospital = h.hospital;

UPDATE doctor_sort t,
 doctor_status s
SET t.hospital_grade = s.grade,
 t.doctorProfession = s.doctorProfession
WHERE
	t.doctorName = s.doctorName;

-- 医生评价指标表与主表连接
CREATE TABLE ultimate SELECT
	m.*, d.comment_score,
	d.number_of_comments,
	d.doctorProfession,
	d.hospital_grade
FROM
	data_doc_dis_topic_f_weight m
LEFT JOIN doctor_sort d ON m.doctorName = d.doctorName;

-- 增加按时间加权后的评论有用性
CREATE TABLE ultra_ultimate SELECT
	o.*, (o.useful) * (
		TIMESTAMPDIFF(DAY, '2007-1-1', o.Vitime) / 3229
	) usefulre
FROM
	ultimate o;

-- 选取所需字段
SELECT
	ME,
	MC,
	CS,
	MAP,
	OP,
	F,
	POP,
	SOP,
	DIS,
	usefulre,
	disease_cat,
	comment_score,
	number_of_comments,
	doctorProfession,
	hospital_grade
FROM ultra_ultimate;
