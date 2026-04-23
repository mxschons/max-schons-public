#!/usr/bin/env ruby
# encoding: UTF-8
# Builds a landing page per life area listing its FAQs, checklists, templates,
# preferences, TSVs, and other markdown files. Writes to _area_pages/
# (included via _config.yml). Runs before `jekyll build`.

require "fileutils"
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

OUTPUT_DIR = "_area_pages"
FileUtils.rm_rf(OUTPUT_DIR)
FileUtils.mkdir_p(OUTPUT_DIR)

AREAS = %w[global life-admin social travel self-care professional]
AREA_BLURB = {
  "global"       => "Cross-domain and identity-level content.",
  "life-admin"   => "Services, logistics, life infrastructure.",
  "social"       => "People and relationships.",
  "travel"       => "Places.",
  "self-care"    => "Practices and routines.",
  "professional" => "Work, career, projects."
}

def title_from_md(path)
  File.foreach(path) do |line|
    return line.sub(/^# /, "").strip if line.start_with?("# ")
  end
  File.basename(path, ".md").tr("-", " ").capitalize
end

def area_title(area)
  area.split("-").map(&:capitalize).join(" ")
end

AREAS.each do |area|
  next unless Dir.exist?(area)

  faqs        = Dir.glob("#{area}/faq/*.md").sort
  checklists  = Dir.glob("#{area}/checklists/*.md").sort
  templates   = Dir.glob("#{area}/templates/*.md").sort
  tsvs        = Dir.glob("#{area}/*.tsv").sort
  preferences = File.exist?("#{area}/preferences.md") ? "#{area}/preferences.md" : nil
  other_md    = Dir.glob("#{area}/*.md").reject { |p| p == preferences }.sort

  File.open(File.join(OUTPUT_DIR, "#{area}.md"), "w") do |f|
    f.puts "---"
    f.puts "layout: page"
    f.puts "title: #{area_title(area)}"
    f.puts "permalink: /#{area}/"
    f.puts "---"
    f.puts
    f.puts AREA_BLURB[area] if AREA_BLURB[area]
    f.puts

    if !faqs.empty?
      f.puts "## FAQ"
      f.puts
      f.puts "[All #{area_title(area)} FAQs]({{ '/#{area}/faq/' | relative_url }}) — #{faqs.size} #{faqs.size == 1 ? 'question' : 'questions'}."
      f.puts
      faqs.each do |p|
        slug = File.basename(p, ".md")
        f.puts "- [#{title_from_md(p)}]({{ '/#{area}/faq/#{slug}' | relative_url }})"
      end
      f.puts
    end

    if !checklists.empty?
      f.puts "## Checklists"
      f.puts
      checklists.each do |p|
        slug = File.basename(p, ".md")
        f.puts "- [#{title_from_md(p)}]({{ '/#{area}/checklists/#{slug}' | relative_url }})"
      end
      f.puts
    end

    if !templates.empty?
      f.puts "## Templates"
      f.puts
      templates.each do |p|
        slug = File.basename(p, ".md")
        f.puts "- [#{title_from_md(p)}]({{ '/#{area}/templates/#{slug}' | relative_url }})"
      end
      f.puts
    end

    if preferences
      f.puts "## Preferences"
      f.puts
      f.puts "- [How I like operational things done in #{area_title(area).downcase}]({{ '/#{area}/preferences' | relative_url }})"
      f.puts
    end

    if !tsvs.empty?
      f.puts "## Tables"
      f.puts
      tsvs.each do |p|
        name = File.basename(p, ".tsv")
        f.puts "- [#{name.tr('-', ' ').capitalize}]({{ '/#{area}/#{name}/' | relative_url }})"
      end
      f.puts
    end

    if !other_md.empty?
      f.puts "## Other"
      f.puts
      other_md.each do |p|
        slug = File.basename(p, ".md")
        f.puts "- [#{title_from_md(p)}]({{ '/#{area}/#{slug}' | relative_url }})"
      end
      f.puts
    end

    if faqs.empty? && checklists.empty? && templates.empty? && preferences.nil? && tsvs.empty? && other_md.empty?
      f.puts "_Nothing here yet._"
    end
  end
end

puts "Rendered #{AREAS.count { |a| Dir.exist?(a) }} area index page(s)."
