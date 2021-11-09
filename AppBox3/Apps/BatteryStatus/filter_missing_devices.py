import json
from os import device_encoding

apple_device_list = open('Apple_mobile_device_types.txt', 'r')

with open('device_information.json') as json_file:
    device_data = json.load(json_file)
platform_list = device_data['platform']

platform_list_keys = list(platform_list.keys())

device_list = apple_device_list.readlines()

for device in device_list:
    components = device.partition(':')
    # print(components[0], components[2])
    device_id = components[0].strip()
    
    # print(len(platform_list_keys[0]), len(device_id))
    if not device_id.startswith('Watch'):
        if (platform_list_keys.count(device_id) == 0):
            print(device_id, components[2])

print("Verifying device information")

device_information = device_data['deviceInformation']
for platform in platform_list_keys:
    device_name = platform_list[platform]
    if not device_name in device_information:
        print(platform, device_name)

print("\n\n")    
print("Verifying remainingTimeInfo")

remainingTimeInfo = device_data['remainingTimeInfo']
for platform in platform_list_keys:
    device_name = platform_list[platform]
    if not device_name in remainingTimeInfo:
        print(platform, device_name)