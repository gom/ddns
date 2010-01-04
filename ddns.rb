#!/usr/bin/ruby
#-*- coding: utf-8 -*-
require 'open-uri'
require 'yaml'

pwd = File.dirname(File.expand_path(__FILE__))
$: << File.join(pwd, 'lib')
$: << File.join(pwd, 'config')

require 'lib/client'
