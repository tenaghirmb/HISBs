# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class XywySpider(CrawlSpider):
    name = 'xywy'
    allowed_domains = ['xywy.com']
    start_urls = ['http://www.xywy.com/', 'http://www.xywy.com/sitemap.html']

    rules = (
        Rule(LinkExtractor(allow_domains=('xywy.com',)),
             callback='parse_url', follow=True),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            try:
                item = UrlextractItem()
                item['site'] = 'xywy'
                url = re.search('www\.xywy\.com/.*?/', response.url).group()
                item['url'] = url
                yield item
            except AttributeError:
                pass
