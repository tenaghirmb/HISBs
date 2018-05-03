# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class QiuyiSpider(CrawlSpider):
    name = 'qiuyi'
    allowed_domains = ['qiuyi.cn']
    start_urls = ['http://www.qiuyi.cn/', 'http://www.qiuyi.cn/company/map']

    rules = (
        Rule(LinkExtractor(allow_domains=('qiuyi.cn',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'qiuyi'
            item['url'] = response.url
            yield item
            try:
                try:
                    url = re.search('http.*?qiuyi.*?/.*?/',
                                    response.url).group()
                except AttributeError:
                    url = re.search('.*?qiuyi.cn/', response.url).group()
                item = UrlextractItem()
                item['site'] = 'qiuyi'
                item['url'] = url
                yield item
            except AttributeError:
                pass
