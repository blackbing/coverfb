module Jasmine
  class Config
    # Retrieve the spec files via Sprockets
    def spec_files
      spec_files = []
      env = Rails.application.assets
      env.each_logical_path do |lp|
        spec_files << lp if lp =~ %r{^spec/.*\.js$}
      end
      spec_files
    end
  end
end

module Jasmine
  def self.runner_template
    File.read(File.join(File.dirname(__FILE__), "run.html.erb"))
  end
end
