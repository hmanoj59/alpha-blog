require 'aws-sdk'
require_relative '../../skejuler/aws/connector'
require 'logger'

module Skejuler
  module Aws

    class Rds
      class Mylog

        def self.log
          if @logger.nil?
            @logger = Logger.new STDOUT
            @logger.level = Logger::INFO
          end
          @logger
        end

      def self.start(rds)
        # logger = Logger.new(STDOUT)
        puts "Enter the DB Instance Identifier"
        dbinstanceidentifier = gets.chomp
        puts "Enter the DB Snapshot Identifier"
        dbsnapshotidentifier = gets.chomp

        begin

        dbsnapshots = rds.db_snapshots({
                                           db_instance_identifier: dbinstanceidentifier,
                                           db_snapshot_identifier: dbsnapshotidentifier,
                                           # snapshot_type: "String",
                                           # filters: [
                                           #     {
                                           #         name: "String", # required
                                           #         values: ["String"], # required
                                           #     },
                                           # ],
                                           # max_records: 1,
                                           # marker: "String",
                                           # include_shared: false,
                                           # include_public: true,
                                       })


        dbsnapshots.first.restore({
                                          db_instance_identifier: dbsnapshotidentifier, # required
                                          # db_instance_class: "String",
                                          # port: 1,
                                          # availability_zone: "String",
                                          # db_subnet_group_name: "String",
                                          multi_az: false,
                                          publicly_accessible: true,
                                          # auto_minor_version_upgrade: false,
                                          # license_model: "String",
                                          # db_name: "String",
                                          # engine: "String",
                                          # iops: 1,
                                          # option_group_name: "String",
                                          # tags: [
                                          #     {
                                          #         key: "String",
                                          #         value: "String",
                                          #     },
                                          # ],
                                          # storage_type: "String",
                                          # tde_credential_arn: "String",
                                          # tde_credential_password: "String",
                                          # domain: "String",
                                          # copy_tags_to_snapshot: false,
                                          # domain_iam_role_name: "String",
                                      })


        rescue => err
          log
        @logger.error( "Could not find the required snapshot, please enter the details again")
        @logger.error(start(rds))
        end


      end

      def self.stop(rds)



        puts "Enter the db instance you need to perform the action"
        # dbInstanceID = "sql"
        # rds = Aws::RDS::Resource.new( )
        dbInstance=rds.db_instance("sql")
        dbInstance.delete({
                      skip_final_snapshot: false,
                      final_db_snapshot_identifier:"sql1"
        # + ((Time.now).strftime("%Y-%d-%m-%I-%M-%S")),
                  })
        puts "Deleting the instance this may take few minutes"
      end


    end
    end

  end
end
