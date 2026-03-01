
# coding: utf-8

# In[ ]:


# -*- coding: utf-8 -*-
import pymysql.cursors
import pandas as pd
import os
import textwrap
import math
import logging


# In[ ]:


logging.basicConfig(filename='calibration.log', level=logging.INFO)


# In[ ]:


sql = textwrap.dedent("""
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
""")


# In[ ]:


def query(sql):
    try:
        connection = pymysql.connect(host='localhost',
                                     user='root',
                                     password=os.environ.get('mysql_password', '960728'),
                                     db='hdf',
                                     charset='utf8mb4',
                                     cursorclass=pymysql.cursors.DictCursor)
        with connection.cursor() as cursor:
            cursor.execute(sql)
            result = cursor.fetchall()
            return pd.DataFrame(result, columns=result[0].keys())
    finally:
        connection.close()


# In[ ]:


def segment(df, condition, cname):
    for n, x in df.groupby([df['disease_cat'], condition]):
        doccap = 'high' if n[1] else 'low'
        filename = n[0] + '_' + cname + '_' + doccap + '.csv'
        x.reset_index(drop=True, inplace=True)
        n1, n2, n3 = x.usefulre.quantile([0.95, 0.5, 0.05]).round(2)
        logging.info("%-20s  calibrate(usefulre,%.2f,%.2f,%.2f)" % (filename, n1, n2, n3))
        x.to_csv(filename, columns=['DR', 'SR', 'PR', 'usefulre'])


# In[ ]:


df = query(sql)
df = df.astype({'ME':'float','MC':'float','CS':'float','MAP':'float','OP':'float','F':'float','POP':'float','SOP':'float','DIS':'float',})


# In[ ]:


# [1] 合并类别（mean）
df['DR'] = df[['ME','MC','MAP','CS']].mean(axis=1)
df['SR'] = df[['F','OP']].mean(axis=1)
df['PR'] = df[['POP','SOP','DIS']].mean(axis=1)


# In[ ]:


# [2] 合并类别（max）
df['DR'] = df[['ME','MC','MAP','CS']].max(axis=1)
df['SR'] = df[['F','OP']].max(axis=1)
df['PR'] = df[['POP','SOP','DIS']].max(axis=1)


# In[ ]:


df.iloc[:,-3:] = df.iloc[:,-3:].div(df.iloc[:,-3:].max(axis=1), axis='index')
df.usefulre = df.usefulre.apply(lambda x: math.log(x+1, 10))
df.comment_score = df.comment_score.apply(lambda x: math.log(x+0.01, 10))
df.number_of_comments = df.number_of_comments.apply(lambda x: math.log(x, 10))


# In[ ]:


segment(df, df['doctorProfession'].isin(['副主任医师','主任医师']), 'title')
segment(df, df['hospital_grade'].isin(['三甲','三级']), 'grade')

