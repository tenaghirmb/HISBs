# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class BjdoctorSpider(CrawlSpider):
    name = 'bjdoctor'
    allowed_domains = ['bj-doctor.cn']
    start_urls = ['http://www.bj-doctor.cn/',
                  'http://www.bj-doctor.cn/sitemap/']

    rules = (
        Rule(LinkExtractor(allow_domains=('bj-doctor.cn',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'bjdoctor'
            item['url'] = response.url
            yield item
            try:
                try:
                    url = re.search('http.*?www.*?bj-doctor.*?/.*?/',
                                    response.url).group()
                except AttributeError:
                    url = re.search('.*?bj-doctor.cn/', response.url).group()
                item = UrlextractItem()
                item['site'] = 'bjdoctor'
                item['url'] = url
                yield item
            except AttributeError:
                pass
