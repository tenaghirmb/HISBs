# -*- coding: utf-8 -*-

import requests
from bs4 import BeautifulSoup
from brexcel.wexcel import WExcel


TABLE = []
URL = "http://search.top.chinaz.com/Search.aspx?p={p}&url=%E8%88%AA%E7%A9%BA"


def parse(url):
    r = requests.get(url)
    r.encoding = 'utf-8'
    soup = BeautifulSoup(r.text, 'lxml')
    items = soup.select('.listCentent')[0]
    items = items.select('li')
    for item in items:
        name = item.select('.pr10.fz14')[0].text.strip()
        link = item.select('.col-gray')[0].text.strip()
        tmp = {'name': name, 'url': link}
        TABLE.append(tmp)


def toExcel(table, filename, tablename):
    f = WExcel(table)
    f.header_order = ['url', 'name']
    f.header_alias = {'url': 'url', 'name': 'name'}
    f.SaveExcelAs(filename, tablename)


if __name__ == '__main__':
    pool = [URL.format(p=str(p)) for p in range(1, 6)]
    for url in pool:
        parse(url)
    filename = 'airFlight.xlsx'
    tablename = 'airFlightSites'
    toExcel(TABLE, filename, tablename)
