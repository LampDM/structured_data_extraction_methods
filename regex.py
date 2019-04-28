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
#       can we improve this?
author_name_pattern = r'<div class="author-name">(.*?)</div>'
publish_meta_pattern = r'\d{2}\.\s\w*\s\d{4}\s\w{2}\s\d{2}:\d{2}'  # example: DD. month YYYY ob HH:MM
article_title_pattern = r'<h1>(.*)</h1>'  # this is not safe, but there is only one heading tag on news page
article_subtitle_pattern = r'<div class="subtitle">(.*?)</div>'
article_lead_pattern = r'<p class="lead">(.*?)</p>'
article_content_pattern = r'<p class=\"Body\">(.*?)</p>|<p>(.*?)</p>'


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
    """ This is ugly. :( refactor?
    """

    def preprocess(html: str):
        # return re.sub(r"^[\s\n\t]+", "", line, flags=re.MULTILINE)
        return ''.join([line.strip() for line in html.splitlines() if line.strip()])

    def remove_tags(line: str):
        """ Clean retrieved content
        """
        return re.sub('<[^<>]+>', '', line)

    def get_author_name(html: str):
        return remove_tags(re.search(author_name_pattern, html).group(0)).strip()

    def get_published_time(html: str):
        return re.search(publish_meta_pattern, html).group(0).strip()

    def get_title(html: str):
        return remove_tags(re.search(article_title_pattern, html).group(0)).strip()

    def get_subtitle(html: str):
        return remove_tags(re.search(article_subtitle_pattern, html).group(0)).strip()

    def get_lead(html: str):
        return remove_tags(re.search(article_lead_pattern, html).group(0)).strip()

    def get_content(html: str):
        lines = list()

        for group in re.findall(article_content_pattern, html):
            filtered_group = list(filter(None, group))
            if filtered_group:
                lines.append(remove_tags(filtered_group[0]))

        return ' '.join(filter(None, lines))

    with open(file_path, 'r', encoding="utf-8") as fp:
        html_content = preprocess(fp.read())

        payload = {
            'Author': get_author_name(html_content),
            'PublishedTime': get_published_time(html_content),
            'Title': get_title(html_content),
            'SubTitle': get_subtitle(html_content),
            'Lead': get_lead(html_content),
            'Content': get_content(html_content),
        }

        return to_json(payload)


def parse_overstock_content(file_path: str):
    def clean_data(match_result: dict):
        match_result['SavingPercent'] = match_result['SavingPercent'].strip().replace('(', '').replace(')', '')
        match_result['Content'] = match_result['Content'].strip().replace('\n', ' ').replace('\t', ' ')
        return match_result

    with open(file_path, 'r', encoding="latin-1") as fp:
        html_content = fp.read()
        payload = {
            'listing': [clean_data(match.groupdict()) for match in re.finditer(overstock_listing_pattern, html_content)]
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
