# Run as `ruby import_language.rb es path/to/site.es.json`
require 'json'
require 'fileutils'
require 'ruby-lokalise-api'
require 'open-uri'
require 'zip'
require 'metadown'
require 'set'
require 'yaml'
require_relative '_plugins/common'


def language_dir(lang)
  "_sections/*/#{lang}"
end


LOKALISE_TOKEN = ARGV[0]
SINGLE_LANG = ARGV[1]
LOKALISE_PROJECT_ID = "423383895e6b8c4b081a89.98184174"

SOURCE_LANG = "en"
SOURCE_DIR = language_dir(SOURCE_LANG)

SECTIONS_TO_FILES = {}
Dir["#{SOURCE_DIR}/**/*.md"].sort!.each { |filename|
  SECTIONS_TO_FILES[key_from_filename(filename)] = filename
}

TOP_LEVEL_PAGES = {}
Dir["*-en.md"].sort!.each { |filename|
  TOP_LEVEL_PAGES[key_from_top_level_file(filename)] = filename
}

STRINGS = YAML.load(File.open("_data/#{SOURCE_LANG}/strings.yml", 'r:UTF-8') { |f| f.read })

CONFIG_YML = File.open("_config.yml", 'r:UTF-8') { |f| f.read }
SUPPORTED_LANGS = YAML.load(CONFIG_YML)['languages']
SCI_REVIEW_CFG = YAML.load(CONFIG_YML)['sci_review_notice_config']
NEW_LANGS = []

def should_have_sci_review_notice(lang, section, translated_file, no_review_keys: [])
  # Check if review notices are enabled for this language
  return false if SCI_REVIEW_CFG['explicitly_disabled_for_languages'].include? lang
  return false if !SCI_REVIEW_CFG['enabled_by_default'] and !SCI_REVIEW_CFG['explicitly_enabled_for_languages'].include? lang

  return false if translated_file !~ /act_and_prepare/
  return false if !no_review_keys.include? section
  # Exclude  /00-blah.md headers
  return false if File.basename(translated_file) =~ /^00-/
  return true
end

def generate_content(lang, translations, no_review_keys: [])
  FileUtils.rm_r(Dir[language_dir(translations_lang)], force: true)

  SECTIONS_TO_FILES.each do |section, source_file|
    translated_file = source_file.sub("/en/", "/#{translations_lang}/")
    translated_dir = File.dirname(translated_file)
    FileUtils.mkdir_p(translated_dir)
    File.open(translated_file, "w:UTF-8") { |file|
      content = translations[section]
      if should_have_sci_review_notice(lang, section, translated_file, no_review_keys: no_review_keys)
        puts "Adding scientific-review disclaimer to #{lang} #{section}"
        # Find the last header line and insert after it.
        lines = content.lines
        last_hdr = lines.rindex{|e| e =~ /^#/}
        if last_hdr == nil
          puts "Missing header lines in #{translated_file}"
          last_hdr = 0
        else
          last_hdr = last_hdr + 1
        end
        lines.insert(last_hdr, "\n{% include pending-sci-review.html %}\n")
        content = lines.join("")
      end
      file.puts content
    }
  end

  TOP_LEVEL_PAGES.each do |page, source_file|
    source_content = File.open(source_file, 'r:UTF-8') { |f| f.read }
    metadata = Metadown.render(source_content).metadata
    metadata["lang"] = translations_lang
    metadata["title"] = translations["#{page}-title"] if translations["#{page}-title"]
    translated_file = source_file.sub(/-en.md$/, "-#{translations_lang}.md")
    File.open(translated_file, "w:UTF-8") { |file|
      file.puts metadata.to_yaml
      file.puts "---\n"
      file.puts metadata["translate_content"] == false ? content_without_frontmatter(source_content) : translations[page]
    }
  end

  translated_strings_dir = "_data/#{translations_lang}"
  translated_strings = Hash[STRINGS.map { |key, value| [key, translations[key]] }]
  FileUtils.mkdir_p(translated_strings_dir)
  File.open("#{translated_strings_dir}/strings.yml", 'w:UTF-8') {|f| f.puts translated_strings.to_yaml }
  NEW_LANGS << translations_lang unless SUPPORTED_LANGS.include? translations_lang
end

def fetch_json_from_lokalise(lang: nil, filter_data: ['translated'])
  client = Lokalise.client LOKALISE_TOKEN
  params = {
    format: "json",
    filter_filename: ["pasted.json"],
    replace_breaks: false,
    placeholder_format: :icu,
    filter_data: filter_data
  }
  if lang != nil
    params['filter_langs'] = [lang]
  end
  resp = client.download_files(LOKALISE_PROJECT_ID, params)
  result = {}
  Zip::File.open_buffer(open(resp["bundle_url"])) { |zip|
    zip.each do |entry|
      next unless entry.name.end_with?("pasted.json")
      file_lang = entry.name.split("/")[0]
      result[file_lang] = JSON.parse(entry.get_input_stream.read)
    end
  }
  result
end

def keys_without_reviews(everything, reviewed)
  everything.keys.to_set - reviewed.keys.to_set
end


puts "Fetching translations from Lokalise"
all_translations = fetch_json_from_lokalise(lang: SINGLE_LANG)
all_reviews = Hash.new
begin 
  all_reviews = fetch_json_from_lokalise(lang: SINGLE_LANG, filter_data: ['reviewed']) 
rescue Lokalise::Error::NotAcceptable => e
  puts "No reviewed keys found for given language"
end

puts "Translations fetched: #{all_translations.keys}"

puts "Writing translation files"
all_translations.each {|lang, json| 
  File.open("_translations/#{lang}.json", "w:UTF-8") { |f| f.write(JSON.pretty_generate(json)) }
}

all_translations.each {|lang, translations|
  reviews = all_reviews[lang]
  reviews = Hash.new if reviews.nil?
  not_reviewed = keys_without_reviews(translations, reviews)
  puts "Generating content files for language #{lang}"
  generate_content(lang, translations, no_review_keys: not_reviewed)
}

unless NEW_LANGS.empty?
  puts "Languages to add: #{NEW_LANGS}"
  languages_regex = /^languages: (\[.*\])$/
  if CONFIG_YML =~ languages_regex
    new_languages_line = "languages: #{(SUPPORTED_LANGS + NEW_LANGS).to_s}"
    new_config_yml = CONFIG_YML.sub languages_regex, new_languages_line
    File.open('_config.yml', 'w:UTF-8') { |f| f.puts new_config_yml }
  end
end
