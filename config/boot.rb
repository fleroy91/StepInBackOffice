require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

class Hash
  def collect!(&block)
    ret = []
    self.each {|key,val|
      if val.kind_of? Array
        val.collect!{|subval|
          block.call subval
        }
        ret = val
      end
    }
   	return ret
  end
end