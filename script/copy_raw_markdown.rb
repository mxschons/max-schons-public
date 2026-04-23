#!/usr/bin/env ruby
# encoding: UTF-8
# Copies source .md files into _site at their permalink paths so the raw
# markdown is served alongside the rendered HTML.
#
# Example: life-admin/faq/how-i-organize-my-contacts.md
#   → _site/life-admin/faq/how-i-organize-my-contacts.md
#
# Run AFTER `jekyll build`.

require "fileutils"
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

SITE_DIR = "_site"
unless Dir.exist?(SITE_DIR)
  abort "ERROR: #{SITE_DIR}/ not found. Run `jekyll build` first."
end

SKIP_PREFIXES = %w[_site/ vendor/ _faq_pages/ _tsv_pages/ _llms/ docs/].freeze
ALWAYS_SKIP = %w[README.md CHANGELOG.md].freeze

count = 0
Dir.glob("**/*.md").each do |path|
  next if SKIP_PREFIXES.any? { |p| path.start_with?(p) }
  next if ALWAYS_SKIP.include?(path)

  dest = File.join(SITE_DIR, path)
  FileUtils.mkdir_p(File.dirname(dest))
  FileUtils.cp(path, dest)
  count += 1
end

puts "Copied #{count} raw .md file(s) into #{SITE_DIR}/."
