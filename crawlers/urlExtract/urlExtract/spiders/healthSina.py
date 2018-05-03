# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class HealthsinaSpider(CrawlSpider):
    name = 'healthSina'
    allowed_domains = ['health.sina.com.cn']
    start_urls = ['http://health.sina.com.cn/',
                  'http://drug.health.sina.com.cn/default.html',
                  'http://slide.health.sina.com.cn/',
                  'http://talk.health.sina.com.cn/',
                  'http://tags.health.sina.com.cn/',
                  'http://news.sina.com.cn/guide/',
                  'http://health.sina.com.cn/disease/ku/',
                  'http://health.sina.com.cn/disease/']

    rules = (
        Rule(LinkExtractor(allow_domains=('health.sina.com.cn',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            try:
                item = UrlextractItem()
                item['site'] = 'healthSina'
                url = re.search('.*?health\.sina\.com\.cn/.*?/',
                                response.url).group()
                item['url'] = url
                yield item
            except AttributeError:
                pass
