#!/bin/bash



function vagrant_up()
{
status=$(vagrant status | grep ans | awk '{print $2}' )
if [ "$status" == "running" ]; then
  get_stats
  printf '{"ip": "%s", "port": "%s", "user": "%s", "key": "%s", "status": "%s", "os_name": "%s", "ram": "%s"}' "$ip" "$port" "$user" "$key" "$status" "$os_version" "$mem_total"
  exit 0
else
  vagrant up &> /dev/null
  get_stats
  status=$(vagrant status | grep ans | awk '{print $2}' )
  printf '{"ip": "%s", "port": "%s", "user": "%s", "key": "%s", "status": "%s", "os_name": "%s", "ram": "%s"}' "$ip" "$port" "$user" "$key" "$status" "$os_version" "$mem_total"
  exit 0
fi
}

function vagrant_halt()
{
status=$(vagrant status | grep ans | awk '{print $2}')
  if [ "$status" == "running" ]; then
      vagrant halt &>/dev/null
      status=$(vagrant status | grep ans | awk '{print $2}')
      printf '{ "status": "%s"}' "$status"
      exit 0
  else
      changed="false"
      failed="false"
      printf '{"status": "%s"}' "$status"
  fi
}

function vagrant_destroy()
{
status=$(vagrant status | grep ans | awk '{print $2}')
  if [ "$status" == "running" ] || [ "$status" == "poweroff" ]; then
      vagrant destroy --force &>/dev/null
      status=$(vagrant status | grep ans | awk '{print $2" "$3}')
      printf '{"failed": false, "changed": true, "status": "%s"}' "$status"
      exit 0
  else
      status=$(vagrant status | grep ans | awk '{print $2" "$3}')
      printf '{"failed": false, "changed": true, "status": "%s"}' "$status"
  fi
}

function get_stats()
{
  ip=$(vagrant ssh-config | grep HostName | awk '{print $2}')
  port=$(vagrant ssh-config | grep Port | awk '{print $2}')
  user=$(vagrant ssh-config | grep User | head -n 1 |awk '{print $2}')
  key=$(vagrant ssh-config | grep IdentityFile | awk '{print $2}')
  os_version=$(vagrant ssh -c "cat /etc/redhat-release" 2> /dev/null | awk '{print $1" " $4}')
  mem_total=$(vagrant ssh -c "cat /proc/meminfo" 2> /dev/null | grep MemTotal |  awk '{print $2/(1024*1024) "Gb"}')
}

source $1

case $state in
    started)
        vagrant_up
    ;;
    stopped)
        vagrant_halt
    ;;
    destroyed)
        vagrant_destroy
    ;;
    *)
        printf '{"failed": true, "msg": "invalid state selected {started | stopped | destroyed}"}'
        exit 1
    ;;
esac