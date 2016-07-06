require 'skejuler-aws'
require '/Users/hotas/Desktop/skejuler-aws/lib/skejuler/aws/rds.rb'

 class SkejulerController < ApplicationController
   def rdstest
     my_aws = {
       region: ENV['AWS_REGION'],
       access_method: 'api_key',
       access_key: ENV['AWS_API_KEY'],
       secret_key: ENV['AWS_SECRET_KEY']
     }

    #  config.autoload_paths += %W(#{config.root}/lib)
    puts "Enter the db instance you need to perform the action"
    rds_instance_id = gets.chomp

      ::Skejuler::Aws::Rds.start(rds_instance_id, my_aws)
      
      redirect_to root_path
   end
 end
