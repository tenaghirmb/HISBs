# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class Fh21Spider(CrawlSpider):
    name = 'fh21'
    allowed_domains = ['fh21.com.cn']
    start_urls = ['http://www.fh21.com.cn/',
                  'http://www.fh21.com.cn/company/sitemap.htm',
                  'http://www.fh21.com.cn/jibing.html']

    rules = (
        Rule(LinkExtractor(allow_domains=('fh21.com.cn',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'fh21'
            item['url'] = response.url
            yield item
            try:
                try:
                    url = re.search('http.*?fh21.*?/.*?/',
                                    response.url).group()
                except AttributeError:
                    url = re.search('.*?fh21\.com\.cn/', response.url).group()
                item = UrlextractItem()
                item['site'] = 'fh21'
                item['url'] = url
                yield item
            except AttributeError:
                pass
