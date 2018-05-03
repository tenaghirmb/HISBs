# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class VodjkSpider(CrawlSpider):
    name = 'vodjk'
    allowed_domains = ['vodjk.com']
    start_urls = ['http://www.vodjk.com/']

    rules = (
        Rule(LinkExtractor(allow_domains=('vodjk.com',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'vodjk'
            item['url'] = response.url
            yield item
            try:
                try:
                    url = re.search('http.*?www.*?vodjk.*?/.*?/',
                                    response.url).group()
                except AttributeError:
                    url = re.search('.*?vodjk.com/', response.url).group()
                item = UrlextractItem()
                item['site'] = 'vodjk'
                item['url'] = url
                yield item
            except AttributeError:
                pass
