# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class Fx120Spider(CrawlSpider):
    name = 'fx120'
    allowed_domains = ['fx120.net']
    start_urls = ['http://www.fx120.net/', 'http://www.fx120.net/sitemap.html']

    rules = (
        Rule(LinkExtractor(allow_domains=('fx120.net',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'fx120'
            item['url'] = response.url
            yield item
            try:
                try:
                    url = re.search('http.*?www.*?fx120.*?/.*?/',
                                    response.url).group()
                except AttributeError:
                    url = re.search('.*?fx120.net/', response.url).group()
                item = UrlextractItem()
                item['site'] = 'fx120'
                item['url'] = url
                yield item
            except AttributeError:
                pass
