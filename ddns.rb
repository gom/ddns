#!/usr/bin/ruby
#-*- coding: utf-8 -*-
pwd = File.dirname(File.expand_path(__FILE__))
$: << pwd unless $:.include?(pwd)

require 'open-uri'
require 'yaml'

require 'lib/client'
