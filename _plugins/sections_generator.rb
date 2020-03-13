module Reading
  class Generator < Jekyll::Generator
    def generate(site)
      dir = "en"
      site.data['sections'] = Dir["#{dir}/**/*.md"].sort!

      full_md_content = StringIO.new
      site.data['sections'].each do |file|
        key = key_from_filename(file)
        content = File.open(file, 'r:UTF-8') { |f| f.read }
        full_md_content << content
        full_md_content << "\n\n"
      end

      md_converter = site.find_converter_instance(Jekyll::Converters::Markdown)
      full_html_content = md_converter.convert(full_md_content.string)
      toc = Jekyll::TableOfContents::Parser.new(full_html_content).build_toc
      site.data['toc'] = toc
    end
  end
end
