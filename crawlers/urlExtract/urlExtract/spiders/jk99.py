# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class Jk99Spider(CrawlSpider):
    name = 'jk99'
    allowed_domains = ['99.com.cn']
    start_urls = ['http://www.99.com.cn/', 'http://www.99.com.cn/sitemap.html']

    rules = (
        Rule(LinkExtractor(allow_domains=('99.com.cn',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'jk99'
            item['url'] = response.url
            yield item
            try:
                try:
                    url = re.search('http.*?www.*?99.*?/.*?/',
                                    response.url).group()
                except AttributeError:
                    url = re.search('.*?99.com.cn/', response.url).group()
                item = UrlextractItem()
                item['site'] = 'jk99'
                item['url'] = url
                yield item
            except AttributeError:
                pass
