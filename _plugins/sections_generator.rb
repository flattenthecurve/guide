require "date"

module SectionsGenerator
class Generator < Jekyll::Generator
  def generate(site)
    site.data['last_updated'] = {}

    pack_content(site, "home_sections")
    pack_content(site, "act_and_prepare")
  end
  
  def pack_content(site, page)
    site.data[page] = {}
    page_toc = page + "_toc"
    site.data[page_toc] = {}

    site.languages.each do |lang|

      dir = "_#{page}/#{lang}"
      site.data[page][lang] = Dir["#{dir}/**/*.md"].sort!

      full_md_content = StringIO.new
      
      puts "packing data for #{page} in #{lang}"

      site.data[page][lang].each do |file|
      key = key_from_filename(file)
        content = File.open(file, 'r:UTF-8') { |f| f.read }
        full_md_content << content
        full_md_content << "\n\n"
      end

      md_converter = site.find_converter_instance(Jekyll::Converters::Markdown)
      full_html_content = md_converter.convert(full_md_content.string)
      toc = Jekyll::TableOfContents::Parser.new(full_html_content).build_toc
      site.data[page_toc][lang] = toc

      last_updated =
        begin
          DateTime.parse(%x(git log -n 1 --pretty=format:"%ai" #{dir})).to_time.utc
        rescue
          DateTime.now - 7
        end
        
        site.data['last_updated'][lang] = last_updated.strftime("%b %e, %Y %l:%M %p (%Z)")
      end
    end
  end
end


