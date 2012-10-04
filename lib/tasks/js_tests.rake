# from http://www.zendesk.com/blog/javascript-loves-ci

namespace :jasmine do

  task :require_phantom_js do
    sh "which phantomjs" do |ok, res|
      fail 'Cannot find phantomjs on $PATH' unless ok
    end
  end

  task :phantom => ['jasmine:require', 'jasmine:require_phantom_js'] do
    support_dir = File.expand_path('../../spec/javascripts/support', File.dirname(__FILE__))
    config_overrides = File.join(support_dir, 'jasmine_config.rb')
    require config_overrides if File.exists?(config_overrides)
    phantom_js_runner = File.join(support_dir, 'run-jasmine.js')

    port = ENV['JASMINE_PORT'] || 8888
    jasmine_url = "http://localhost:#{port}"
    puts "Running tests against #{jasmine_url}"
    sh "phantomjs #{phantom_js_runner} #{jasmine_url}" do |ok, res|
      fail 'Jasmine specs failed' unless ok
    end
  end

end
