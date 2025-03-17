#!/bin/bash

service_name="run_stress"

if systemctl is-active --quiet "$service_name"; then
  :
else 
  sudo systemctl start $service_name
fi

service_name1="status"

if systemctl is-active --quiet "$service_name1"; then
  :
else 
  sudo systemctl start $service_name1
fi

service_name2="dotnet-be"

if systemctl is-active --quiet "$service_name2"; then
  :
else 
  sudo systemctl start $service_name2
fi
