# -*- coding : utf-8 -*-

import requests
from bs4 import BeautifulSoup
from brexcel.wexcel import WExcel

TABLE = []
URL = 'http://life.hao123.com/health'

r = requests.get(URL)
soup = BeautifulSoup(r.text, 'lxml')
div = soup.select('.health-tuiguang-wrapper.clearfix')[0]
categories = div.select('.tuiguang-list.clearfix')
for ul in categories:
    category = ul.select('.tuiguang-title')[0].text.strip()[:4]
    detail = ul.select('.tuiguang-detail-list.clearfix')[0].find_all('li')
    for li in detail:
        name = li.a.text
        url = li.a.get('href')
        tmp = {'name': name, 'url': url, 'category': category}
        TABLE.append(tmp)

f = WExcel(TABLE)
f.header_order = ['url', 'name', 'category']
f.header_alias = {'url': 'url', 'name': 'name', 'category': 'category'}
f.SaveExcelAs('healthsites.xlsx', 'healthsite')
