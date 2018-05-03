# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class HaodfSpider(CrawlSpider):
    name = 'haodf'
    allowed_domains = ['haodf.com']
    start_urls = ['http://www.haodf.com/']

    rules = (
        Rule(LinkExtractor(allow_domains=('haodf.com',)),
             callback='parse_url', follow=True),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            try:
                item = UrlextractItem()
                item['site'] = 'haodf'
                url = re.search('.*?\.haodf\.com/', response.url).group()
                item['url'] = url
                yield item
            except AttributeError:
                pass
