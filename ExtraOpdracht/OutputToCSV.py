import re

import pandas as pd

delimiter = '___________________________________________________________________________'

in_file = "inventory-list - kopie.txt"
out_file_csv = "csv_allnex.csv"
out_file_xlsx = "allnex_inventory.xlsx"
out_file_pids = "pids.txt"

countLines = 0
hostname = ""
ip = ""
stackmember = ""
product_id = ""
serial = ""
countDevices = 0
output = ""
pids = ""

toRemove = ['Power Supply', 'GigabitEthernet', 'Module', 'Stack', 'Te', 'Gi', 'Chassis']


# 'FRU Uplink Module','FlexStackPlus Module','FRULink Slot 1 - FRULink Module','FlexStack Module'


def checkLine(regex, text, group=1):
    substring = re.search("{}".format(regex), text)
    if substring is not None:
        return substring.group(group)
    return None


def checkStackmember(string, substrings):
    return any(substring in string for substring in substrings)


def CSVtoExel(in_file, out_file):
    pd.read_csv(in_file).to_excel(out_file, index=None, header=True)


with open(in_file) as fp:
    for line in fp:
        countLines += 1

        hostname_and_ip = checkLine('(.*)\\):', line, 0)
        stackmemberLine = checkLine('NAME:(.*), DESCR:', line)
        pid_and_sn = checkLine('PID(.*)', line)

        if hostname_and_ip is not None:
            hostname = checkLine('(.*) \\(', hostname_and_ip)
            ip = checkLine('\\((.*)\\):', hostname_and_ip)
            countDevices += 1

        if stackmemberLine is not None:
            stackmember = stackmemberLine.strip().replace('"', "")

        if pid_and_sn is not None:
            product_id = checkLine(': (.*) VID', pid_and_sn).strip(',').strip()
            serial = checkLine('SN:(.*)', pid_and_sn).strip()


        if hostname != "" and ip != "" and stackmember != "" and checkStackmember(stackmember,
                                                                                  toRemove) == False and product_id != "" and serial != "":
            csvline = '{},{},{},{},{}\n'.format(hostname, ip, stackmember, product_id, serial)

            if product_id not in pids:
                pids += "{}\n".format(product_id)

            if csvline not in output:
                output += csvline

        if delimiter in line:
            print('Device: {}'.format(countDevices))
            hostname = ""
            ip = ""
            stackmember = ""

        product_id = ""
        serial = ""


f = open(out_file_csv, "a")
f.write('HOSTNAME,IP,STACKMEMBER,PRODUCT ID, SERIAL\n')
f.write(output)

f = open(out_file_pids,"a")
f.write(pids)

CSVtoExel(out_file_csv, out_file_xlsx)
