#!/bin/bash
for i in `/usr/local/bin/expand_mcommgrp "$1"`
do
  usermod -g "$2" $i
done

