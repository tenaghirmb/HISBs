# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class Ask120Spider(CrawlSpider):
    name = 'ask120'
    allowed_domains = ['120ask.com']
    start_urls = ['http://www.120ask.com/',
                  'http://zxmr.120ask.com/',
                  'http://tag.120ask.com/',
                  'http://yp.120ask.com/']

    rules = (
        Rule(LinkExtractor(allow_domains=('120ask.com',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'ask120'
            item['url'] = response.url
            yield item
            try:
                try:
                    url = re.search('http.*?www.*?com/.*?/',
                                    response.url).group()
                except AttributeError:
                    url = re.search('.*?120ask\.com/', response.url).group()
                item = UrlextractItem()
                item['site'] = 'ask120'
                item['url'] = url
                yield item
            except AttributeError:
                pass
