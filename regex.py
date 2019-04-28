"""

Regular expressions implementation:

For each given web page type implement a separate function that will take HTML code as input.
The method should output extracted data in a JSON structured format to a standard output.
Each data item must be directly extracted using a regular expression.

"""
import re
import sys
import json

# NOTE: regex patterns for rtvslo.si news page structure
rtv_article_pattern = r'<div class=\"news-container (?:.*?)\">' +\
                      r'[\s\S]+<h1>(?P<Title>.+)</h1>[\s\S]+' +\
                      r'<div class=\"subtitle\">(?P<SubTitle>.+)' +\
                      r'</div>[\s\S]*?<strong>(?P<Author>.*?)</strong>\|' +\
                      r'\s(?P<PublishedTime>\d{2}\.\s\w*\s\d{4}\s\w{2}\s\d{2}:\d{2})[\s\S]+' +\
                      r'<p class=\"lead\">(?P<Lead>.*?)</p>[\s\S]+' +\
                      r'<article class=\"article\">[\s\S]*?(?P<Content><p>([\s\S]+)</p>|<p (?:.+?)>[\s\S]+</p>)' +\
                      r'[\s\S]*</article>'

# NOTE: regex pattern for overstock.com jewelry listing
overstock_listing_pattern = r'<td valign=\"top\">[\s]+?<a [^<>]+><b>(?P<Title>.*?)</b></a>' +\
                            r'[\s\S]+?(?P<listPrice>\$\d+.\d+)' +\
                            r'[\s\S]+?(?P<Price>\$\d+.\d+)' +\
                            r'[\s\S]+?(?P<Saving>\$\d+.\d+)' +\
                            r'(?P<SavingPercent>\s\(\d+?%\))' +\
                            r'[\s\S]+?<span class=\"normal\">(?P<Content>[^<>]+)'


def to_json(payload: dict):
    print(json.dumps(payload, ensure_ascii=False, indent=4), file=sys.stdout)


def parse_rtv_content(file_path: str):
    def _remove_tags(pattern: str):
        """ Replace html tags in pattern using re.
        """
        return re.sub('<[^<>]+>', '', pattern)

    def _clean_data(match_result: dict):
        match_result['Content'] = _remove_tags(match_result['Content'].replace('\t', '').replace('\n', '').strip())
        return match_result

    with open(file_path, 'r', encoding="utf-8") as fp:
        html_content = fp.read()
        match = re.search(rtv_article_pattern, html_content)
        return to_json(_clean_data(match.groupdict()))


def parse_overstock_content(file_path: str):
    def _clean_data(match_result: dict):
        match_result['SavingPercent'] = match_result['SavingPercent'].strip().replace('(', '').replace(')', '')
        match_result['Content'] = match_result['Content'].strip().replace('\n', ' ').replace('\t', ' ')
        return match_result

    with open(file_path, 'r', encoding="latin-1") as fp:
        html_content = fp.read()
        payload = {
            'listing': [_clean_data(match.groupdict()) for match in re.finditer(overstock_listing_pattern, html_content)]
        }

        return to_json(payload)


if __name__ == "__main__":
    rtv_pages = ['WebPages/rtvslo.si/Audi A6 50 TDI quattro_ nemir v premijskem razredu - RTVSLO.si.html',
                 'WebPages/rtvslo.si/Volvo XC 40 D4 AWD momentum_ suvereno med najboljše v razredu - RTVSLO.si.html']

    overstock_pages = ['WebPages/overstock.com/jewelry01.html',
                       'WebPages/overstock.com/jewelry02.html']

    for page in rtv_pages:
        parse_rtv_content(page)

    for page in overstock_pages:
        parse_overstock_content(page)
