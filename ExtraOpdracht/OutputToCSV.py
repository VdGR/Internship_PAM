import re

new_device = '___________________________________________________________________________'
in_file = "inventory-list - kopie.txt"
out_file = "csv_allnex.csv"

def checkLine(regex, text, group=1):
    substring = re.search("{}".format(regex), text)
    if substring is not None:
        return substring.group(group)
    return None


countLines = 0
hostname = ""
ip = ""
stackmember = ""
product_id = ""
serial = ""
countDevices = 0
with open(in_file) as fp:
    for line in fp:
        countLines += 1

        if checkLine("(.*)\\):", line, 0) is not None:
            hostname_and_ip = checkLine('(.*)\\):', line, 0)
            hostname = checkLine('(.*) \\(', hostname_and_ip)
            ip = checkLine('\\((.*)\\):', hostname_and_ip)
            countDevices += 1

        if checkLine('NAME:(.*), DESCR:', line) is not None:
            stackmember = checkLine('NAME:(.*), DESCR:', line).strip().replace('"', "")

        if checkLine('PID(.*)', line) is not None:
            pid_and_sn = checkLine('PID(.*)', line)
            product_id = checkLine(': (.*) VID',pid_and_sn).strip(',').strip()
            serial = checkLine('SN:(.*)',pid_and_sn).strip()

        if hostname != "" and ip != "" and stackmember != "" and product_id != "" and serial != "":
            csvline = '{},{},{},{},{}\n'.format(hostname, ip, stackmember, product_id, serial)
            f = open(out_file, "a")
            f.write(csvline)

        if new_device in line:
            print('Device: {}'.format(countDevices))
            hostname = ""
            ip = ""
            stackmember = ""
            product_id = ""
            serial = ""


