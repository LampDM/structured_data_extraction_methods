"""

Regular expressions implementation:

For each given web page type implement a separate function that will take HTML code as input.
The method should output extracted data in a JSON structured format to a standard output.
Each data item must be directly extracted using a regular expression.

"""
import re

# NOTE: regex patterns for rtvslo.si news page structure
#       can we improve this?
author_name_pattern = r'<div class="author-name">(.*)</div>'
# example: DD. month YYYY ob HH:MM
publish_meta_pattern = r'\d{2}\.\s\w*\s\d{4}\s\w{2}\s\d{2}:\d{2}'


def remove_tags(line: str):
    """ Remove html tags from the retrieved content.
    """
    return re.sub('<[^<>]+>', '', line)


def read_html_file(file_path: str):
    with open(file_path, 'r') as fp:
        return fp.read()


def get_author_name(page_content: str):
    return remove_tags(re.search(author_name_pattern, page_content).group(0))


def get_published_time(page_content: str):
    return remove_tags(re.search(publish_meta_pattern, page_content).group(0))


def get_title():
    raise NotImplementedError


def get_subtitle():
    raise NotImplementedError


def get_lead():
    raise NotImplementedError


def get_content():
    raise NotImplementedError


if __name__ == "__main__":
    rtv_pages = ['WebPages/rtvslo.si/Audi A6 50 TDI quattro_ nemir v premijskem razredu - RTVSLO.si.html',
                 'WebPages/rtvslo.si/Volvo XC 40 D4 AWD momentum_ suvereno med najboljše v razredu - RTVSLO.si.html']

    content = read_html_file(rtv_pages[0])
    out_json = {
        'Author': get_author_name(content),
        'PublishedTime': get_published_time(content),
    }

    print(out_json)
