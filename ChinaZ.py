# -*- coding: utf-8 -*-

import requests
from bs4 import BeautifulSoup
from brexcel.wexcel import WExcel


TABLE = []
URL = 'http://top.chinaz.com/hangye/index_yiliao_wap{page}.html'


def parse(url):
    r = requests.get(url)
    r.encoding = 'utf-8'
    soup = BeautifulSoup(r.text, 'lxml')
    items = soup.select('.listCentent')[0]
    items = items.select('li')
    for item in items:
        name = item.select('.pr10.fz14')[0].text.strip()
        link = item.select('.col-gray.mobicon')[0].text.strip()
        rank = item.select('.col-red02')[0].text.strip()
        tmp = {'name': name, 'url': link, 'rank': int(rank)}
        TABLE.append(tmp)


def toExcel(table, filename, tablename):
    f = WExcel(table)
    f.header_order = ['url', 'name', 'rank']
    f.header_alias = {'url': 'url', 'name': 'name', 'rank': 'rank'}
    f.SaveExcelAs(filename, tablename)


if __name__ == '__main__':
    pool = [URL.format(page='_' + str(p)) for p in range(2, 8)]
    pool.append(URL.format(page=''))
    for url in pool:
        parse(url)
    filename = 'wapSites.xlsx'
    tablename = 'wapSites'
    toExcel(TABLE, filename, tablename)
