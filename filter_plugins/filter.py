import re


def get_mongo_src(arg, os_name, os_version, mongo_version):
    os_name = os_name.lower()
    if os_name == "centos" or "redhat":
        os_name = "rhel"

    for item in arg:
        if re.match('.*' + os_name + os_version + '.*', item, re.M | re.I) and \
                re.match('.*' + mongo_version + '.*', item, re.M | re.I):
            return item

    return "nothing found"


class FilterModule(object):
    def filters(self):
        return {
            'get_mongo_src': get_mongo_src
        }




