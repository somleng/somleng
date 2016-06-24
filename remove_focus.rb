#!/usr/bin/env ruby
founds = `grep -n -r ":focus" spec/`.split("\n")

#path;line_number;matched_content
founds.each do |string|
  array = string.split(":")
  path = array[0]
  line_number = array[1]
  matched_line = array[2..-1].join(':')

  if matched_line.match(/^\s*(describe|context|it).+(:focus do$)/)
    puts "\e[0;32m#{string}\e[0m"
    system "gsed -i '#{line_number} s/,\s*:focus//' #{path}"
  end
end
