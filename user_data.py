#!/usr/bin/python36
import subprocess
import os
import cgi

print("content-type: text/html")
print()

form =  cgi.FieldStorage()
docker_name = form.getvalue('n')
docker_image = form.getvalue('img')
dockers_in_system=subprocess.getoutput("sudo docker ps -a --format '{{.Names}}'")
if(docker_name in dockers_in_system):
  print("<H1>Docker already exist please choose another name.</H1>")
  exit()
else:
  output=subprocess.getoutput("sudo docker run --name {} {}".format(docker_name,docker_image))
  print("<H1>Docker '{}' launched successfully</H1>".format(docker_name))
  docker_in_system=subprocess.getoutput("sudo docker ps -a --format '{{.Names}}'")
  docker_image_in_system=subprocess.getoutput("sudo docker ps -a --format '{{.Image}}'")
  docker_in_system_list=docker_in_system.split()
  docker_image_in_system_list=docker_image_in_system.split()
  print("<H3>Total docker present in system are: {}</H3>".format(len(docker_in_system_list)))
  for i in range(1,len(docker_in_system_list)+1):
    print("<H4>{}. {} ---> {}</H4>".format(i,docker_in_system_list[i-1],docker_image_in_system_list[i-1]))
