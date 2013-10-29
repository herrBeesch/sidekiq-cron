module Sidekiq
  module Cron
    module Web
      def self.registered(app)
        web_dir = File.expand_path("../../../web", __FILE__)
        js_dir = File.join(web_dir, "assets", "javascripts")
        
        app.register Sinatra::AssetPack
        
        app.assets {
          serve '/js', from: js_dir
          js 'jsoneditor', ['/js/jsoneditor.js']
        }
      end
    end
  end
end