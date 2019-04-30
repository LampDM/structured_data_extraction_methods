from lxml import html, etree
import json
import sys


def jewelry():
    for page in ["jewelry01.html", "jewelry02.html"]:
        doc = html.fromstring(open('../WebPages/overstock.com/{}'.format(page)).read())
        count = doc.xpath("/html/body/table[2]/tbody/tr[1]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td/table/tbody/*")

        for i in range(1, len(count) + 1):
            try:
                title = doc.xpath(
                    "/html/body/table[2]/tbody/tr[1]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td/table/tbody/tr[{}]/td[2]/a/b".format(
                        i))[0].text
                content = doc.xpath(
                    "/html/body/table[2]/tbody/tr[1]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td/table/tbody/tr[{}]/td[2]/table/tbody/tr/td[2]/span".format(
                        i))[0].text
                listprice = doc.xpath(
                    "/html/body/table[2]/tbody/tr[1]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td/table/tbody/tr[{}]/td[2]/table/tbody/tr/td[1]/table/tbody/tr[1]/td[2]/s".format(
                        i))[0].text
                price = doc.xpath(
                    "/html/body/table[2]/tbody/tr[1]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td/table/tbody/tr[{}]/td[2]/table/tbody/tr/td[1]/table/tbody/tr[2]/td[2]/span/b".format(
                        i))[0].text
                savingppr = doc.xpath(
                    "/html/body/table[2]/tbody/tr[1]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td/table/tbody/tr[{}]/td[2]/table/tbody/tr/td[1]/table/tbody/tr[3]/td[2]/span".format(
                        i))[0]
                saving, savprcnt = savingppr.text.split(" ")

                out_json = {
                    'title': title,
                    'content': content,
                    'listprice': listprice,
                    'price': price,
                    'saving': saving,
                    'savprcnt': savprcnt
                }

                print(json.dumps(out_json, ensure_ascii=False, indent=4), file=sys.stdout)

            except Exception as ex:
                pass


def cars():
    volvo = "Volvo XC 40 D4 AWD momentum_ suvereno med najboljše v razredu - RTVSLO.si.html"
    pages = ["Audi A6-rendered-again.html",
             volvo]

    def intr(dom):
        if isinstance(dom, html.HtmlElement):
            ctag = dom.tag
            if ctag == "p":
                children = dom.getchildren()
                intr(dom.text)
                for c in children:
                    intr(c)
            elif ctag == "div":
                for el in dom:
                    intr(el)
            elif ctag == "figure":
                for el in dom:
                    intr(el)
            # elif ctag == "img":
            #   intr(dom.attrib['src'])
            elif ctag == "article":
                for el in dom:
                    intr(el)
            # elif ctag == "a":
            #    intr(dom.attrib['href'])
            elif ctag == "strong":
                intr(dom.text)
            elif ctag == "br":
                intr(dom.tail)
            else:
                pass
        else:
            if dom is not None:
                if "./" in dom:
                    pass
                else:
                    nonlocal content
                    content += str(dom)

    for page in pages:
        doc = html.fromstring(open('../WebPages/rtvslo.si/{}'.format(page), encoding="ansi").read())
        "/html/body/div[10]/div[3]/div/div[1]/div[1]/div"
        author = doc.xpath("/html/body/div[9]/div[3]/div/div[1]/div[1]/div")[0].text
        publishedt = doc.xpath("/html/body/div[9]/div[3]/div/div[1]/div[2]")[0].text
        title = doc.xpath("/html/body/div[9]/div[3]/div/header/h1")[0].text
        subtitle = doc.xpath("/html/body/div[9]/div[3]/div/header/div[2]")[0].text
        lead = doc.xpath("/html/body/div[9]/div[3]/div/header/p")[0].text
        articlebody = doc.xpath("/html/body/div[9]/div[3]/div/div[2]")[0]

        content = ""
        intr(articlebody)

        # Elimination of unwanted characters
        if "<!--" in content:
            content = content.split("-->")[1]
        publishedt = publishedt.replace("\n", "").replace("\t", "")

        out_json = {
            'Title': title,
            'SubTitle': subtitle,
            'Author': author,
            'PublishedTime': publishedt,
            'Lead': lead,
            'Content': content
        }

        print(json.dumps(out_json, ensure_ascii=False, indent=4), file=sys.stdout)


jewelry()
cars()
