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

author_name_pattern = r'<div class="author-name">(.*)</div>'
publish_meta_pattern = r'\d{2}\.\s\w*\s\d{4}\s\w{2}\s\d{2}:\d{2}'  # example: DD. month YYYY ob HH:MM
article_title_pattern = r'<h1>(.*)</h1>'  # this is not safe, but there is only one heading tag on news page
article_subtitle_pattern = r'<div class="subtitle">(.*)</div>'
article_lead_pattern = r'<p class="lead">(.*)</p>'
article_body_pattern = r'<article class=\"article\">([\s\S]*)<\/article>'
article_content_pattern = r'<p>(.*)<\/p>'


def remove_tags(line: str):
    """ Remove html tags from the retrieved content.
    """
    return re.sub('<[^<>]+>', '', line)


def read_html_file(file_path: str):
    with open(file_path, 'r') as fp:
        return fp.read()


def get_author_name(page_content: str):
    return remove_tags(re.search(author_name_pattern, page_content).group(0)).strip()


def get_published_time(page_content: str):
    return re.search(publish_meta_pattern, page_content).group(0).strip()


def get_title(page_content: str):
    return remove_tags(re.search(article_title_pattern, page_content).group(0)).strip()


def get_subtitle(page_content: str):
    return remove_tags(re.search(article_subtitle_pattern, page_content).group(0)).strip()


def get_lead(page_content: str):
    return remove_tags(re.search(article_lead_pattern, page_content).group(0)).strip()


def get_content(page_content: str):
    article_body = re.search(article_body_pattern, page_content).group(0).strip()
    return ' '.join((remove_tags(group) for group in re.findall(article_content_pattern, article_body)))


def parse_page_content(file_path: str):
    content = read_html_file(file_path)

    out_json = {
        'Author': get_author_name(content),
        'PublishedTime': get_published_time(content),
        'Title': get_title(content),
        'SubTitle': get_subtitle(content),
        'Lead': get_lead(content),
        'Content': get_content(content),
    }

    print(json.dumps(out_json, ensure_ascii=False, indent=4), file=sys.stdout)


if __name__ == "__main__":
    rtv_pages = ['WebPages/rtvslo.si/Audi A6 50 TDI quattro_ nemir v premijskem razredu - RTVSLO.si.html',
                 'WebPages/rtvslo.si/Volvo XC 40 D4 AWD momentum_ suvereno med najboljše v razredu - RTVSLO.si.html']

    for page in rtv_pages:
        parse_page_content(page)
