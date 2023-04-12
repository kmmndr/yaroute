namespace :active_storage do
  desc 'Raise an error unless the RAILS_ENV is development'
  task development_environment_only: :environment do
    raise 'Hey! Development only, you monkey!' unless Rails.env.development? || Rails.env.test?
  end

  namespace :bucket do
    desc 'Drop active-storage bucket'
    task drop: [:environment, :development_environment_only] do
      abort('Storage other than S3') unless ActiveStorage::Blob.service.class.name == 'ActiveStorage::Service::S3Service'

      bucket_name = ActiveStorage::Blob.service.bucket.name

      begin
        puts "Deleting bucket #{bucket_name}"
        ActiveStorage::Blob.service.client.bucket(bucket_name).delete
      rescue Aws::S3::Errors::NoSuchBucket
        puts "Bucket #{bucket_name} does not exists yet"
      end
    end

    desc 'Create bucket for active-storage'
    task create: [:environment, :development_environment_only] do
      abort('Storage other than S3') unless ActiveStorage::Blob.service.class.name == 'ActiveStorage::Service::S3Service'

      bucket_name = ActiveStorage::Blob.service.bucket.name

      if ActiveStorage::Blob.service.client.bucket(bucket_name).exists?
        puts "Bucket #{bucket_name} already exists"
      else
        puts "Creating bucket #{bucket_name}"
        ActiveStorage::Blob.service.client.create_bucket(bucket: bucket_name)
      end
    end

    desc 'Recreate bucket for active-storage'
    task reset: [:drop, :create]
  end
end
