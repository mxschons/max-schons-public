#!/usr/bin/env ruby
# encoding: UTF-8
# Lints ${VARNAME} tokens across repo content vs .env.example declarations.
# Exits with status 1 if any tokens are used but not declared, so CI fails.

require "set"
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

EXAMPLE_FILE = ".env.example"

declared = Set.new
if File.exist?(EXAMPLE_FILE)
  File.foreach(EXAMPLE_FILE) do |line|
    if line =~ /^([A-Z_][A-Z0-9_]*)=/
      declared << $1
    end
  end
end

used_by_file = Hash.new { |h, k| h[k] = Set.new }
Dir.glob("**/*.{md,tsv}").each do |path|
  next if path.start_with?("_site/", "vendor/", "_faq_pages/", "_tsv_pages/")
  in_fence = false
  File.foreach(path) do |line|
    if line.start_with?("```")
      in_fence = !in_fence
      next
    end
    next if in_fence
    # Strip inline code spans (`...`) before scanning for tokens.
    scrubbed = line.gsub(/`[^`]*`/, "")
    scrubbed.scan(/\$\{([A-Z_][A-Z0-9_]*)\}/).each { |m| used_by_file[path] << m[0] }
  end
end

all_used = used_by_file.values.reduce(Set.new, :|)

missing = all_used - declared
orphan  = declared - all_used

if missing.any?
  puts "ERROR: Tokens used in content but not declared in #{EXAMPLE_FILE}:"
  missing.sort.each do |var|
    files = used_by_file.select { |_, vs| vs.include?(var) }.keys
    puts "  ${#{var}}  (in: #{files.join(", ")})"
  end
end

if orphan.any?
  puts "WARN:  Tokens declared in #{EXAMPLE_FILE} but not used anywhere:"
  orphan.sort.each { |var| puts "  #{var}" }
end

if missing.empty? && orphan.empty?
  puts "OK: #{all_used.size} token(s) in content, all declared; no orphans."
end

exit(missing.empty? ? 0 : 1)
