# -*- coding: utf-8 -*-
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from urlExtract.items import UrlextractItem
import re


class FamilydoctorSpider(CrawlSpider):
    name = 'familydoctor'
    allowed_domains = ['familydoctor.com.cn']
    start_urls = ['http://www.familydoctor.com.cn/',
                  'http://www.familydoctor.com.cn/sitemap.html']

    rules = (
        Rule(LinkExtractor(allow_domains=('familydoctor.com.cn',)),
             callback='parse_url', follow=False),
    )

    def parse_url(self, response):
        if len(response.url) < 100:
            item = UrlextractItem()
            item['site'] = 'familydoctor'
            url = re.search('www\.familydoctor\.com\.cn\/.*?\/.*',
                            response.url).group()
            item['url'] = url
            yield item
