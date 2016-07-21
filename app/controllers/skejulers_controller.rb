require 'skejuler-aws'
# require '/Users/hotas/Desktop/skejuler-aws/lib/skejuler/aws/rds.rb'
require '/Users/hotas/Desktop/skejuler-aws/lib/skejuler/aws/ec2.rb'


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

  def ec2start
    ec2_client = Aws::EC2::Client.new(
        region: ENV['AWS_REGION'],
        access_key_id: ENV['AWS_API_KEY'],
        secret_access_key: ENV['AWS_SECRET_KEY']
    )

    ::Skejuler::Aws::Rds::Mylog.start(ec2_client)
    redirect_to root_path
  end

  def ec2stop
    ec2_client = Aws::EC2::Client.new(
        region: ENV['AWS_REGION'],
        access_key_id: ENV['AWS_API_KEY'],
        secret_access_key: ENV['AWS_SECRET_KEY']
    )

    ::Skejuler::Aws::Rds::Mylog.stop(ec2_client)
    redirect_to root_path
  end
end
