require 'aws-sdk'
class StartstopinsController < ApplicationController

  def start()

    ec2_client = Aws::EC2::Client.new(
      # region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_API_KEY'],
      secret_access_key: ENV['AWS_SECRET_KEY']
  )

  ec2_client.start_instances({
                                           instance_ids: ["i-85a007b4"], # required
                                           # additional_info: "String",
                                           dry_run: false,
                                       })
            puts "Instance started"

  # ec2_client.stop_instances({
  #                                     dry_run: false,
  #                                     instance_ids: ["i-85a007b4"], # required
  #                                     force: false,
  #                                 })
redirect_to root_path
      end
    end
