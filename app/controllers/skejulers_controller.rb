require 'skejuler-aws'
require '/Users/hotas/Desktop/skejuler-aws/lib/skejuler/aws/rds.rb'

class SkejulersController < ApplicationController

  def rdsstart

    rds = Aws::RDS::Resource.new(
        region: ENV['AWS_REGION'],
        access_key_id: ENV['AWS_API_KEY'],
        secret_access_key: ENV['AWS_SECRET_KEY']
    )


    ::Skejuler::Aws::Rds::Mylog.start(rds)
    # Rails.logger.info "My info log"

    redirect_to root_path

  end

  def rdsstop

    rds = Aws::RDS::Resource.new(
        region: ENV['AWS_REGION'],
        access_key_id: ENV['AWS_API_KEY'],
        secret_access_key: ENV['AWS_SECRET_KEY']
    )
logger.debug rds.inspect
    ::Skejuler::Aws::Rds::Mylog.stop(rds)
    redirect_to root_path
  end


end
