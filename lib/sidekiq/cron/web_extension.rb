require 'sinatra/assetpack'
module Sidekiq
  module Cron
    module WebExtension
      
      def self.registered(app)

        web_dir = File.expand_path("../../../../web", __FILE__)
        js_dir = File.join(web_dir, "assets", "javascripts")
        css_dir = File.join(web_dir, "assets", "stylesheets")


        app.register Sinatra::AssetPack

        app.assets {
          serve '/js', from: js_dir
          serve '/css', from: css_dir
          js 'jsoneditor', ['/js/jsoneditor.js']
          css 'jsoneditor', ['/css/jsoneditor.css']
        }
        
        #very bad way of loading locales for cron jobs
        #should be rewritten
        app.helpers do

          def no_translation t, what=nil
            t
          end          
        end    
        
        #index page of cron jobs
        app.get '/cron' do   
          view_path    = File.join(File.expand_path("..", __FILE__), "views")          
          @cron_jobs = Sidekiq::Cron::Job.all

          #if Slim renderer exists and sidekiq has layout.slim in views
          if defined?(Slim) && File.exists?(File.join(settings.views,"layout.slim"))
            render(:slim, File.read(File.join(view_path, "cron.slim")))
          else
            render(:erb, File.read(File.join(view_path, "cron.erb")))
          end
        end

        #enque cron job
        app.post '/cron/:name/enque' do |name|
          if job = Sidekiq::Cron::Job.find(name)
            job.enque!
          end
          redirect "#{root_path}cron"
        end

        #delete schedule
        app.post '/cron/:name/delete' do |name|
          if job = Sidekiq::Cron::Job.find(name)
            job.destroy
          end
          redirect "#{root_path}cron"
        end

        #enable job
        app.post '/cron/:name/enable' do |name|
          if job = Sidekiq::Cron::Job.find(name)
            job.enable!
          end
          redirect "#{root_path}cron"
        end

        #disable job
        app.post '/cron/:name/disable' do |name|
          if job = Sidekiq::Cron::Job.find(name)
            job.disable!
          end
          redirect "#{root_path}cron"
        end
        
        #edit job
        app.get '/cron/:name/edit' do |name|
          if @job = Sidekiq::Cron::Job.find(name)
            view_path    = File.join(File.expand_path("..", __FILE__), "views")
            render(:erb, File.read(File.join(view_path, "cron_edit.erb")))
          else
            redirect "#{root_path}cron"
          end
        end
        
        #update job
        app.post '/cron/:name/update' do |name|
          request.body.rewind  # in case someone already read it
          data = JSON.parse request.body.read
          content_type :json
          if data['process_config'].nil?            
            return 400, "{error: {message: 'process_config parameter is missing'}}"      
          end    
          if data['process_config']['cron'].nil?
            return 400, "{error: {message: 'cron parameter in process_config is missing'}}"      
          end
          if data['process_config']['name'].nil?
            return 400, "{error: {message: 'name parameter in process_config is missing'}}"      
          end
          cronData = data['process_config']['cron']
          processName = data['process_config']['name']
          queue = data['process_config']['sidekiq_queue'].blank? ? "default" : data['process_config']['sidekiq_queue']
          begin
            job = Sidekiq::Cron::Job.new( name: processName, cron: cronData, queue: queue, klass: 'GenericCronExportProcess', args: data)
            if job.valid?
              job.save
              return 200, "{message: Job created.}"
            else
              return 400, "{error: {message: 'Could not create job: #{job.errors}'}}"
            end
          rescue Exception => e
            return 500, "{message: 'Something went wrong with #{e.class}: #{e}}'"
          end    
          if @job = Sidekiq::Cron::Job.find(name)
            view_path    = File.join(File.expand_path("..", __FILE__), "views")
            render(:erb, File.read(File.join(view_path, "cron_edit.erb")))
          else
            redirect "#{root_path}cron"
          end
        end
        
      end
    end
  end
end
