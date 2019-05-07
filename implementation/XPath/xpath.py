from lxml import html, etree
import json
import sys


def jewelry(page):
    doc = html.fromstring(open('../../input/overstock.com/{}'.format(page)).read())
    count = doc.xpath("/html/body/table[2]/tbody/tr[1]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td/table/tbody/*")

    for i in range(1, len(count) + 1):
        try:
            title = doc.xpath(
                "//tr[{}]/td[2]/a/b".format(
                    i))[0].text
            content = doc.xpath(
                "//tr[{}]/td[2]/table/tbody/tr/td[2]/span".format(
                    i))[0].text
            listprice = doc.xpath(
                "//tr[{}]/td[2]/table/tbody/tr/td[1]/table/tbody/tr[1]/td[2]/s".format(
                    i))[0].text
            price = doc.xpath(
                "//tr[{}]/td[2]/table/tbody/tr/td[1]/table/tbody/tr[2]/td[2]/span/b".format(
                    i))[0].text
            savingppr = doc.xpath(
                "//tr[{}]/td[2]/table/tbody/tr/td[1]/table/tbody/tr[3]/td[2]/span".format(
                    i))[0]
            saving, savprcnt = savingppr.text.split(" ")

            out_json = {
                'title': title,
                'content': content,
                'listprice': listprice,
                'price': price,
                'saving': saving,
                'savprcnt': savprcnt.replace("(", "").replace(")", "")
            }

            print(json.dumps(out_json, ensure_ascii=False, indent=4), file=sys.stdout)

        except Exception as ex:
            pass


def cars(page):
    content = ""
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

    doc = html.fromstring(open('../../input/rtvslo.si/{}'.format(page), encoding="ansi").read())
    author = doc.xpath("//div[9]/div[3]/div/div[1]/div[1]/div")[0].text
    publishedt = doc.xpath("//div[9]/div[3]/div/div[1]/div[2]")[0].text
    title = doc.xpath("//div[9]/div[3]/div/header/h1")[0].text
    subtitle = doc.xpath("//div[9]/div[3]/div/header/div[2]")[0].text
    lead = doc.xpath("//div[9]/div[3]/div/header/p")[0].text
    articlebody = doc.xpath("//div[9]/div[3]/div/div[2]")[0]


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


def koce(page):
    doc = html.fromstring(open('../../input/Pzs.si/{}'.format(page), encoding="utf-8").read())

    Telefon = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[2]/td[2]")[0].text
    GSM = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[3]/td[2]")[0].text
    TelefonPD = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[4]/td[2]")[0].text
    eMail = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[5]/td[2]/a")[0].text
    Splet = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[6]/td[2]/a/@href")[0]
    Oskrbnik = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[7]/td[2]")[0].text

    NaslovHolder = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[9]/td[2]")[0]
    Naslov = "{}, {}".format(NaslovHolder[0].tail, NaslovHolder[1].tail)

    ZemljepisHolder = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[10]/td[2]")[0]
    ZemljepisnaSirina = ZemljepisHolder.text
    ZemljepisnaDolzina = ZemljepisHolder[0].tail

    LeziscaHolder = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[12]/td[2]")[0]
    Lezisca = LeziscaHolder.text
    for c in LeziscaHolder:
        try:
            Lezisca += c.text
        except Exception as ex:
            pass
        try:
            Lezisca += ", " + c.tail
        except Exception as ex:
            pass

    Jedilnica = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[13]/td[2]")[0].text
    Cenik = ""
    try:
        Cenik = doc.xpath("//tbody/tr[1]/td[2]/table/tbody/tr[14]/td[2]/a/@href")[0]
    except Exception as ex:
        pass

    out_json = {
        "Telefon": Telefon,
        "GSM": GSM,
        "TelefonPD": TelefonPD,
        "eMail": eMail,
        "Splet": Splet,
        "Oskrbnik": Oskrbnik,
        "Naslov": Naslov,
        "ZemljepisnaSirina": ZemljepisnaSirina,
        "ZemljepisnaDolzina": ZemljepisnaDolzina,
        "Lezisca": Lezisca,
        "Jedilnica": Jedilnica,
        "Cenik": Cenik
    }

    print(json.dumps(out_json, ensure_ascii=False, indent=4), file=sys.stdout)


jpages = ["jewelry01.html", "jewelry02.html"]
for p in jpages:
    jewelry(p)

cpages = ["Audi A6-rendered-again.html",
          "Volvo1.html"]
for p in cpages:
    cars(p)

kpages = ["pzs1.html", "pzs2.html"]
for p in kpages:
    koce(p)


