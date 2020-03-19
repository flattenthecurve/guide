require "date"

module SectionsGenerator
  class Generator < Jekyll::Generator
    def generate(site)
      site.data['last_updated'] = {}
      lang = site.active_lang
      dir = "_sections/*/#{lang}"

      last_updated =
        begin
          DateTime.parse(%x(git log -n 1 --pretty=format:"%ai" -- #{dir})).to_time.utc
        rescue
          DateTime.now - 7
        end

      site.data['last_updated'][lang] = last_updated.strftime("%b %e, %Y %l:%M %p (%Z)")
    end
  end
end
