# -*- coding: utf-8 -*-
# @Author: aka
# @Date:   2018-06-20 17:05:08
# @Last Modified by:   aka
# @Last Modified time: 2018-06-22 20:30:01
# @Email: tenag_hirmb@hotmail.com

import pymysql.cursors
import pandas as pd
import os
import matplotlib.pyplot as plt
import textwrap
from scipy import stats
import math
import os

connection = pymysql.connect(host='localhost',
                             user='root',
                             password=os.environ.get('mysql_password', '960728'),
                             db='hdf',
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor)

def query(sql):
    try:
        with connection.cursor() as cursor:
            cursor.execute(sql)
            result = cursor.fetchall()
            return pd.DataFrame(result, columns=result[0].keys())
    finally:
        connection.close()

def dist(sr, srname='Please assign variable name'):
    try:
        plt.figure()
        sr.plot.hist(bins=80)
    except AttributeError:
        sr = pd.Series(sr)
        sr.plot.hist(bins=1000)
    plt.title(srname)
    plt.show()
    return None

def bcdist(sr, srname='Please assign variable name'):
    if sr.min()==0:
        sr = sr.apply(lambda x: x+0.01)
    data, _ = stats.boxcox(sr)
    return dist(sr, srname)

def logdist(sr, srname='Please assign variable name'):
    if sr.min()==0:
        sr = sr.apply(lambda x: x+0.01)
    sr = sr.apply(lambda x: math.log(x, 10))
    return dist(sr, srname)

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
df = query(sql)
df = df.astype({'ME':'float','MC':'float','CS':'float','MAP':'float','OP':'float','F':'float','POP':'float','SOP':'float','DIS':'float',})

df.usefulre = df.usefulre.apply(lambda x: math.log(x+0.01, 10))
df.comment_score = df.comment_score.apply(lambda x: math.log(x+0.01, 10))
df.number_of_comments = df.number_of_comments.apply(lambda x: math.log(x, 10))


# dist(df.comment_score, 'Comment Score')
# dist(df.number_of_comments, 'Number of Comments')
# dist(df.usefulre, 'Comment Usefulness')

def segment(df, condition, cname):
    for n, x in df.groupby([df['disease_cat'],condition]):
        doccap = 'high' if n[1] else 'low'
        filename = n[0] + '_' + cname + '_' + doccap + '.csv'
        x.reset_index(drop=True, inplace=True)
        x.to_csv(filename, columns = ['ME', 'MC', 'CS', 'MAP', 'OP', 'F', 'POP', 'SOP', 'DIS', 'usefulre'])


os.chdir('data')
segment(df, df['doctorProfession'].isin(['副主任医师','主任医师']), 'title')
segment(df, df['hospital_grade'].isin(['三甲','三级']), 'grade')
segment(df, df['number_of_comments'] > df.number_of_comments.median(), 'noc')
segment(df, df['comment_score'] > df.comment_score.median(), 'cs')