# Run as `ruby import_language.rb es path/to/site.es.json`
require 'json'
require 'fileutils'

def usage
  puts "ruby ./import_language es path/to/site.es.json"
  exit 1
end

translations_lang = ARGV[0] || usage()
translations_file = File.open(ARGV[1], 'r').path || usage()

def key_from_filename(name)
  basename = File.basename(name)
  if basename =~ /\d\d-(.*)\.md/
      return $1
  else
      raise "#{basename} doesn't match the \"99-some-file-name.md\" name format (in #{name})"
  end
end

def language_dir(lang)
  "_content/#{lang}"
end
source_lang = "en"
source_dir = language_dir(source_lang)
sections_to_files = {}
Dir["#{source_dir}/**/*.md"].sort!.each { |filename|
  sections_to_files[key_from_filename(filename)] = filename
}

translations = JSON.parse(File.open(translations_file, 'r:UTF-8') { |f| f.read })

FileUtils.rm_r(language_dir(translations_lang))

sections_to_files.each do |section, source_file|
  translated_file = source_file.sub(source_dir, language_dir(translations_lang))
  translated_dir = File.dirname(translated_file)
  FileUtils.mkdir_p(translated_dir)
  File.open(translated_file, "w:UTF-8") { |file|
    file.puts translations[section]
  }
end
