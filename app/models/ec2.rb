require 'aws-sdk'
require 'set'
require_relative 'connector.rb'


# ec2 doc: http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2.html

# backup ec2 instance function
def backup(options = {})
  puts "WELCOME TO BACKINGUP FUNCTION"
  puts "YOU ARE STARTING TO BACK UP EC2 INSTANCE "+ options.fetch(:instance_id)+"  NOW"


  region=options.fetch(:region)
  #connect EC2 resource
  #   ec2_client = Aws::EC2::Client.new(
  #     region: options.fetch(:region),
  #     access_key_id: ENV['AWS_API_KEY'],
  #     secret_access_key: ENV['AWS_SECRET_KEY']
  #
  # )
  # step 0 connect to aws using connector.rb
  puts "step 0:step 0 connect to aws using connector.rb"
  my_aws = {
      region: ENV['AWS_REGION'],
      access_method: 'api_key',
      access_key: ENV['AWS_API_KEY'],
      secret_key: ENV['AWS_SECRET_KEY']
  }
  conn = ::Aws::Connector.new(my_aws)
  ec2_client = conn.ec2 # Aws RDS Client library
  resource = Aws::EC2::Resource.new(client: ec2_client)
  instance_id = options.fetch(:instance_id)
  instance=resource.instance(instance_id)


  # step1 take a snapshot on some specific volumeXs from backup instance
  puts "step1:take a snapshot on some specific volumeXs from backup instance"
  # find boot volume
  bootVolume=nil
  backupInstanceVolumes=instance.volumes
  backupInstanceVolumes.each do |volume|
    if volume.attachments[0].device=="/dev/xvda"
      bootVolume=volume
    end
  end
end


  # step 1.1 Only take root volumes snapshot
  if bootVolume!=nil
    puts "step 1.1: Only take root volume snapshot"
    boot_valume_snapshot=resource.create_snapshot({
                                                      dry_run: false,
                                                      volume_id: bootVolume.id, # required
                                                      description: "snapshot for bootvolume from EC2 instance: "+instance_id,

                                                  })
    # step 1.1.1 creating "Name" tag
    puts "step 1.1.1 creating \"Name\" tag on snapshot "+boot_valume_snapshot.id
    boot_valume_snapshot.create_tags({
                                         dry_run: false,
                                         tags: [ # required
                                             {
                                                 key: "Name",
                                                 value: "EC2 Backup Snapshot"
                                             },
                                         ],
                                     })
    # step 1.1.2 creating "Time" tag
    puts "step 1.1.2 creating \"Time\" tag on snapshot "+boot_valume_snapshot.id
    boot_valume_snapshot.create_tags({
                                         dry_run: false,
                                         tags: [ # required
                                             {
                                                 key: "Time",
                                                 value: Time.new.inspect
                                             },
                                         ],
                                     })
    # step 1.1.3 creating "ec2-id" tag. This tag is for knowing this snapshot is for which instance
    puts "step 1.1.3 creating \"EC2-instanceID\" tag on snapshot "+boot_valume_snapshot.id
    boot_valume_snapshot.create_tags({
                                         dry_run: false,
                                         tags: [ # required
                                             {
                                                 key: "EC2-instanceID",
                                                 value: instance_id
                                             },
                                         ],
                                     })
    # step 1.1.4 creating "EC2-instanceID" tag.
    puts "step 1.1.4 creating \"EC2-instanceID\" tag on snapshot "+boot_valume_snapshot.id
    boot_valume_snapshot.create_tags({
                                         dry_run: false,
                                         tags: [ # required
                                             {
                                                 key: "Volume-type",
                                                 value: "/dev/xvda"
                                             },
                                         ],
                                     })
    # step 1.1.5 creating "volume-type" tag.
    puts "step 1.1.5 creating \"Snapshot from Volume\" tag on snapshot "+boot_valume_snapshot.id
    boot_valume_snapshot.create_tags({
                                         dry_run: false,
                                         tags: [ # required
                                             {
                                                 key: "Snapshot from Volume",
                                                 value: bootVolume.id
                                             },
                                         ],
                                     })

  end


  # step 1.2 Only take block volumes snapshot
  if  instance.volumes.count!=0
    puts "step 1.2: Only take block volumes snapshot"
    instance.volumes.each do |volume|
      if volume.attachments[0].device!="/dev/xvda"
        snapshot =resource.create_snapshot({
                                               dry_run: false,
                                               volume_id: volume.id, # required
                                               description: "snapshot for blockvolume from EC2 instance: "+instance_id,
                                           })
        # step 1.2.1 creating "Name" tag
        puts "step 1.2.1 creating \"Name\" tag on snapshot "+snapshot.id
        snapshot.create_tags({
                                 dry_run: false,
                                 tags: [ # required
                                     {
                                         key: "Name",
                                         value: "EC2 Backup Snapshot",
                                     },
                                 ],

                             })
        # step 1.2.2 creating "Time" tag
        puts "step 1.2.2 creating \"Time\" tag on snapshot "+snapshot.id
        snapshot.create_tags({
                                 dry_run: false,
                                 tags: [ # required
                                     {
                                         key: "Time",
                                         value: Time.now.inspect,
                                     },
                                 ],

                             })
        # step 1.2.3 creating "EC2-instanceID" tag. This tag is for knowing this snapshot is for which instance
        puts "step 1.2.3 creating \"EC2-instanceID\" tag on snapshot "+snapshot.id
        snapshot.create_tags({
                                 dry_run: false,
                                 tags: [ # required
                                     {
                                         key: "EC2-instanceID",
                                         value: instance_id
                                     },
                                 ],
                             })
        # step 1.2.4 creating "volume-type" tag.
        puts "step 1.2.4 creating \"volume-type\" tag on snapshot "+snapshot.id
        snapshot.create_tags({
                                 dry_run: false,
                                 tags: [ # required
                                     {
                                         key: "Volume-type",
                                         value: "/dev/sdf"
                                     },
                                 ],
                             })
      end
    end
  end

end



# restore ec2 instance function
def restore(options = {})
  puts "WELCOME TO RESTORE FUNCTION"
  puts "YOU ARE STARTING TO RESTORE EC2 INSTANCE "+ options.fetch(:instance_id)+"  NOW"
  region=options.fetch(:region)
  availability_zone=options.fetch(:availability_zone)
  #connect EC2 resource
  ec2_client = Aws::EC2::Client.new(
      region: options.fetch(:region),
      access_key_id: ENV['AWS_API_KEY'],
      secret_access_key: ENV['AWS_SECRET_KEY']

  )

  resource = Aws::EC2::Resource.new(client: ec2_client)
  instance_id = options.fetch(:instance_id)
  time        = options.fetch(:time)

  #step1 identify the snapshots from a specific EC2 instance
  puts "step 1: identify the snapshots from EC2 instance "+instance_id
  #step1.1: find the boot volume snapshot
  puts "step 1.1: identify the boot volume snapshot from EC2 instance "+instance_id
  boot_volume_snapshots=resource.snapshots({
                                               dry_run: false,
                                               filters: [
                                                   {
                                                       name: "tag:EC2-instanceID",
                                                       values: [instance_id]
                                                   },
                                                   {
                                                       name: "tag:Volume-type",
                                                       values: ["/dev/xvda"]
                                                   },
                                                   {
                                                       name: "tag:Time",
                                                       values: [time]
                                                   },

                                               ],
                                           })


  boot_volume_snapshot=nil
  boot_volume_snapshots.each do |snapshot|
    boot_volume_snapshot=snapshot
  end

  if boot_volume_snapshot!=nil
    puts "step 1.1: boot_volume_snapshots from the EC2 instance was "+boot_volume_snapshot.id
  else puts "boot_volume not found. Please check your input instance_id paramerter"
  end


  #step1.1 find the block volumes snapshots
  puts "step 1.1: Identify the block volume snapshots from EC2 instance "+instance_id

  block_volume_snapshots=resource.snapshots({
                                                dry_run: false,
                                                filters: [
                                                    {
                                                        name: "tag:EC2-instanceID",
                                                        values: [instance_id]
                                                    },
                                                    {
                                                        name: "tag:Volume-type",
                                                        values: ["/dev/sdf"]
                                                    },
                                                    {
                                                        name: "tag:Time",
                                                        values: [time]
                                                    },
                                                ],
                                            })
  puts "step 1.1: complete"




  #step2 create a volumeY from that snapshot
  puts "step 2: create volumes from snapshots"
  #step2.1 only create boot volume
  puts "step 2.1: only create boot volume"
  boot_volume_snapshot.wait_until_completed
  backup_instance_new_boot_volume= resource.create_volume({
                                                              dry_run: false,
                                                              size: 1,
                                                              snapshot_id: boot_volume_snapshot.id,
                                                              availability_zone: availability_zone, # required
                                                              volume_type: "standard", # accepts standard, io1, gp2, sc1, st1
                                                              encrypted: false,

                                                          })
  # step 2.1.1 creating \"Previous root volume attached to EC2 instance\" tag on the volume
  puts "step 2.1.1 creating \"Previous root volume attached to EC2 instance\" tag on volume "+backup_instance_new_boot_volume.id
  backup_instance_new_boot_volume.create_tags({
                                                  dry_run: false,
                                                  tags: [ # required
                                                      {
                                                          key: "Previous root volume attached to EC2 instance",
                                                          value: instance_id,
                                                      },
                                                      {
                                                          key: "Type",
                                                          value: "Boot_Volume",
                                                      },


                                                      {
                                                          key: "Time",
                                                          value: Time.now.inspect,
                                                      },

                                                  ],
                                              })

  #step2.2 create other volumes except boot volume
  puts "step 2.2: create block volumes"


  backup_instance_new_non_boot_volume_array=[]
  block_volume_snapshots.each do |snapshot|
    snapshot.wait_until_completed
    volume=ec2.create_volume({
                                 dry_run: false,
                                 size: 1,
                                 snapshot_id: snapshot.id,
                                 availability_zone: "us-east-1a", # required
                                 volume_type: "standard", # accepts standard, io1, gp2, sc1, st1
                                 encrypted: false,

                             })
    backup_instance_new_non_boot_volume_array.push(volume)
    # step 2.2.1 creating \"Previous block volume attached to EC2 instance\" tag on the volume
    puts "step 2.2.1 creating \"Previous block volume attached to EC2 instance\" tag on volume "+volume.id
    volume.create_tags({
                           dry_run: false,
                           tags: [ # required
                               {
                                   key: "Previous block volume attached to EC2 instance",
                                   value: instance_id,
                               },
                               {
                                   key: "Type",
                                   value: "Block_Volume",
                               },
                               {
                                   key: "Time",
                                   value: Time.now.inspect,
                               },
                           ],
                       })

  end




  #step3 "Launch a new instanceX" and "stop it" and "detach the root volume"
  puts "step 3: \"Launch a new instanceX\" and \"stop it\" and \"detach the root volume\""

  #step3.1 start create new instance X
  puts "step 3.1: start to create new instance X"
  instancesX=resource.create_instances({
                                           dry_run: false,
                                           image_id: "ami-6869aa05", # amazon Linux
                                           min_count: 1, # required
                                           max_count: 1, # required
                                           instance_type: "t2.micro",
                                           placement: {
                                               availability_zone: "us-east-1a",

                                           }

                                       })

  #step3.1.1 creating \"Restore from Instance\" tag on the instance X
  puts "step 3.1.1: creating \"Restore from Instance\"  tag"
  instancesX.create_tags({
                           dry_run: false,
                           tags: [ # required
                               {
                                   key: "Restore from Instance",
                                   value: instance_id ,
                               },
                           ],
                       })






  instancesX[0].wait_until_running(max_attempts:100,delay:100)
  puts "instanceX: "+instancesX[0].id+" is running"



  #step 3.2 stop instance
  puts "step 3.2: stop instance X: "+instancesX[0].id
  instancesX[0].stop({
                         dry_run: false,
                         force: false,
                     })


  instancesX[0].wait_until_stopped
  puts "step 3.2: stop instance X: "+instancesX[0].id+"was completed"



  #step3.3 detach the root volume
  puts "step 3.3: detach the root volume of instanceX: "+instancesX[0].volumes.first.id
  instancesX[0].detach_volume({
                                  dry_run: false,
                                  volume_id: instancesX[0].volumes.first.id, # required
                                  device: "/dev/xvda", # required/ boot device
                                  force: false,
                              })

  sleep(0.5)
  puts "step 3.3: Root volume of instanceX: "+instancesX[0].id+" was detached"


  #step4 attach the volume
  puts "step 4: Attach the volume to restored instanceX: "+instancesX[0].id
  #step4.1 attach root  volume to instanceX
  puts "step 4.1: Attach root  volume to instanceX: "+instancesX[0].id
  instancesX[0].attach_volume({
                                  dry_run: false,
                                  volume_id: backup_instance_new_boot_volume.id, # required
                                  device: "/dev/xvda", # required root device
                              })
  puts "step 4.1: boot volume to restored instance attached"

  #step4.2 attach block volumes to instanceX
  puts "step 4.2: Attaching block volume to instanceX: "+instancesX[0].id
  backup_instance_new_non_boot_volume_array.each do |new_non_boot_volume|


    instancesX[0].attach_volume({
                                    dry_run: false,
                                    volume_id: new_non_boot_volume.id, # required
                                    device: "/dev/sdf", # required
                                })
  end
  puts "step 4.2: All block volumes attached"
  puts "Restore completed"
  puts "You have successfully restored from EC2 instance:"+instance_id+" to EC2 instance: "+instancesX[0].id
end


# backup  Testing
#backup  instance_id: 'i-011bb42152266b710', region: 'us-east-1'

# restore Testing
restore instance_id: 'i-061a01dca27253a52', region: 'us-east-1', availability_zone:'us-east-1a' , time: '2016-07-01 09:13:32 -0700'
