from lxml import html
import json
import sys

doc = html.fromstring(open('../WebPages/overstock.com/jewelry01.html').read())
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
            'title' : title,
            'content' : content,
            'listprice' : listprice,
            'price' : price,
            'saving' : saving,
            'savprcnt' : savprcnt
        }

        print(json.dumps(out_json, ensure_ascii=False, indent=4), file=sys.stdout)

    except Exception as ex:
        pass

