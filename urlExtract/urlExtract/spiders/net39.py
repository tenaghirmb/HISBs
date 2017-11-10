# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem


class Net39Spider(CrawlSpider):
    name = 'net39'
    allowed_domains = ['39.net']
    start_urls = ['http://www.39.net/', 'http://www.39.net/sitemap/']

    rules = (
        Rule(LinkExtractor(allow_domains=('39.net',)), callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'net39'
            item['url'] = response.url
            yield item
