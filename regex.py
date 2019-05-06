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


pzs_info_pattern = r'<td valign=\"top\"><table width=\"100%\"[\s\S]+?<td [\s\S]+?>(?P<Telefon>\+.+?)</td>' +\
                   r'[\s\S]+?<td [\s\S]+?>(?P<GSM>\+.+?)</td>' +\
                   r'[\s\S]+?<td [\s\S]+?>(?P<TelefonPD>\+.+?)</td>' + \
                   r'[\s\S]+?<a [\s\S]+?>(?P<eMail>.+?)</a>' +\
                   r'[\s\S]+?<a href=\"(?P<Splet>.+?)\"[\s\S]+?>[\s\S]+?</a>' +\
                   r'[\s\S]+?<td [\s\S]+?\"padding-left:20px;\">(?P<Oskrbnik>.+?)</td></tr>' +\
                   r'[\s\S]+?</a></span>(?P<Naslov>.+?)</td>' +\
                   r'[\s\S]+?(?P<ZemljepisnaSirina>\d{2},[\d]+?)<br>(?P<ZemljepisnaDolzina>\d{2},[\d]+?)</td>' +\
                   r'[\s\S]+?\">[^<>]+(?P<Lezisca>.+ - .+?)</td>' +\
                   r'[\s\S]+?(?P<Jedilnica>[\d]+?\s\w+)</td>[\s\S]+?<a href=\"(?P<Cenik>.+?)\"[\s\S]+?>[\s\S]+?</a>'


def to_json(payload: dict):
    print(json.dumps(payload, ensure_ascii=False, indent=4), file=sys.stdout)


def remove_tags(pattern: str):
    """ Replace html tags in pattern using re.
    """
    return re.sub('<[^<>]+>', '', pattern)


def parse_rtv_content(file_path: str):

    def _clean_data(match_result: dict):
        match_result['Content'] = remove_tags(match_result['Content'].replace('\t', '').replace('\n', '').strip())
        return match_result

    with open(file_path, 'r', encoding="latin-1") as fp:
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


def parse_pzs_content(file_path: str):
    def _clean_data(match_result: dict):
        _lezisca = match_result['Lezisca'].replace('<br>', ', ')
        match_result['Lezisca'] = remove_tags(_lezisca.replace('\t', '').replace('\n', '').strip())
        match_result['Naslov'] = match_result['Naslov'].replace('<br>', ', ')
        return match_result

    with open(file_path, 'r', encoding="utf-8") as fp:
        html_content = fp.read()
        match = re.search(pzs_info_pattern, html_content)
        return to_json(_clean_data(match.groupdict()))


if __name__ == "__main__":
    rtv_pages = ['WebPages/rtvslo.si/Audi A6-rendered-again.html',
                 'WebPages/rtvslo.si/Volvo XC 40-rendered-again.html']

    overstock_pages = ['WebPages/overstock.com/jewelry01.html',
                       'WebPages/overstock.com/jewelry02.html']

    pzs_pages = ['WebPages/Pzs.si/PZS  Triglavski dom na Kredarici.html',
                 'WebPages/Pzs.si/PZS  Vojkova koča na Nanosu.html']

    for page in rtv_pages:
        parse_rtv_content(page)

    for page in overstock_pages:
        parse_overstock_content(page)

    for page in pzs_pages:
        parse_pzs_content(page)
