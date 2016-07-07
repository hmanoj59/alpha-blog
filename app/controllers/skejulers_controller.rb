require 'skejuler-aws'
require '/Users/hotas/Desktop/skejuler-aws/lib/skejuler/aws/rds.rb'

 class SkejulersController < ApplicationController
   def rdstest
     my_aws = {
       region: ENV['AWS_REGION'],
       access_method: 'api_key',
       access_key: ENV['AWS_API_KEY'],
       secret_key: ENV['AWS_SECRET_KEY']
     }

    #  config.autoload_paths += %W(#{config.root}/lib)

      rds_instance_id = "sql"
      ::Skejuler::Aws::Rds.start(rds_instance_id, my_aws)

      redirect_to root_path
   end
 end
