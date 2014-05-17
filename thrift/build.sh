#! /bin/sh

#clean up old stuff
rm -rf gen-*

#generate latest
thrift -r --gen js:node --gen cocoa GoonbeeChatService.thrift
