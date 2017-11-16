# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class GuahaoSpider(CrawlSpider):
    name = 'guahao'
    allowed_domains = ['guahao.com']
    start_urls = ['http://www.guahao.com/']

    rules = (
        Rule(LinkExtractor(allow_domains=('guahao.com',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'guahao'
            item['url'] = response.url
            yield item
            try:
                try:
                    url = re.search('http.*?www.*?guahao.*?/.*?/',
                                    response.url).group()
                except AttributeError:
                    url = re.search('.*?guahao.com/', response.url).group()
                item = UrlextractItem()
                item['site'] = 'guahao'
                item['url'] = url
                yield item
            except AttributeError:
                pass
