# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem


class HealthpeopleSpider(CrawlSpider):
    name = 'healthPeople'
    allowed_domains = ['health.people.com.cn']
    start_urls = ['http://health.people.com.cn/']

    rules = (
        Rule(LinkExtractor(allow_domains=('health.people.com.cn',)),
             callback='parse_url', follow=True),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'healthPeople'
            item['url'] = response.url
            yield item
