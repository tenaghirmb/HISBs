# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class Yst39Spider(CrawlSpider):
    name = 'yst39'
    allowed_domains = ['39yst.com']
    start_urls = ['http://www.39yst.com/']

    rules = (
        Rule(LinkExtractor(allow_domains=('39yst.com',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'yst39'
            item['url'] = response.url
            yield item
            try:
                try:
                    url = re.search('http.*?www.*?39yst.*?/.*?/',
                                    response.url).group()
                except AttributeError:
                    url = re.search('.*?39yst.com/', response.url).group()
                item = UrlextractItem()
                item['site'] = 'yst39'
                item['url'] = url
                yield item
            except AttributeError:
                pass
