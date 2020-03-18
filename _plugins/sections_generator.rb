require "date"

module SectionsGenerator
  class Generator < Jekyll::Generator
    def generate(site)
      site.data['last_updated'] = {}

      pack_content(site, "home_sections", site.active_lang)
      pack_content(site, "act_and_prepare", site.active_lang)
    end

    def pack_content(site, page, lang)
      site.data[page] = {}

      dir = "_#{page}/#{lang}"
      site.data[page][lang] = Dir["#{dir}/**/*.md"].sort!

      puts "packing data for #{page} in #{lang}"

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
