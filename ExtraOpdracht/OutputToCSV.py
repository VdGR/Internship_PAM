import re
import csv


def findSome(right, text):
    substring = re.search('(.+?){}'.format(right), text)
    if substring is not None:
        return substring.group(0)
    return None

def findName(text):
    substring = re.search('NAME:(.*), DESCR:', text)
    if substring is not None:
        return substring.group(1)
    return None

def findPIDandSN(text):
    substring = re.search('PID(.*)', text)
    if substring is not None:
        return substring.group(1)
    return None


#with open('devices.csv', mode='w') as employee_file:
#    csv_writer = csv.writer(employee_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
#    csv_writer.writerow([hostname, ip, stackmember, product_id, serial])

count = 0

hostname = ""
ip = ""
stackmember = ""
product_id = ""
serial = ""
with open("inventory-list - kopie.txt") as fp:

    for line in fp:

        count += 1
        #print("Line{}: {}".format(count, line.strip()))
        #hostname = findSome('coatings.com',line)
        hostname_ip = findSome('\\):', line)
        if findSome('\\):', line) is not None:
            hostname = re.search('(.*) \\(', hostname_ip).group(1)
            ip = re.search('\\((.*)\\):', hostname_ip).group(1)
        if findName(line) is not None:
            stackmember = findName(line).replace('"','')
        if findPIDandSN(line) is not None:
            product_id = re.search(': (.*) VID', findPIDandSN(line)).group(1).strip(' ').strip(',')
            serial = re.search('SN:(.*)', findPIDandSN(line)).group(1).strip(' ')



        #print(hostname,ip,stackmember,product_id,serial)
        csvline = '{},{},{},{},{}\n'.format(hostname,ip,stackmember,product_id,serial)
       # if hostname is not None & ip is not None


        #if (hostname == '' && ip == '' ):

        f = open("csv_allnex.csv", "a")
        f.write(csvline)



        if '___________________________________________________________________________' in line:
            #print('New Device')
            hostname = ""
            ip = ""
            stackmember = ""
            product_id = ""
            serial = ""



        #print(findSome('\\):', line))





