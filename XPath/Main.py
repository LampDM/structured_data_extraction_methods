from lxml import html, etree

doc = html.fromstring(open('../WebPages/overstock.com/jewelry01.html').read())
count = doc.xpath("/html/body/table[2]/tbody/tr[1]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td/table/tbody/*")

for i in range(1, len(count) + 1):
    try:
        titlepath = doc.xpath(
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
        print([titlepath,content,listprice,price,saving,savprcnt])

    except Exception as ex:
        pass

