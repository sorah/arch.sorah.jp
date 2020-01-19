#!/usr/bin/env ruby
require 'aws-sdk-s3'
require 'fileutils'
require 'yaml'

def s3_fetch(region, bucket, key, dest, error: true)
  puts "==> #{region}; s3://#{bucket}/#{key} => #{File.join(Dir.pwd, dest)}"
  s3 = Aws::S3::Client.new(region: region)
  File.open("#{dest}.progress", 'w') do |io|
    s3.get_object(
      bucket: bucket,
      key: key,
      response_target: io,
    )
  end
  File.rename "#{dest}.progress", dest
  true
rescue Aws::S3::Errors::NotFound, Aws::S3::Errors::AccessDenied, Aws::S3::Errors::NoSuchKey
  raise if error
  return false
end

def s3_put(src, region, bucket, key)
  puts "==> #{region}; #{File.join(Dir.pwd, src)} => s3://#{bucket}/#{key}"
  s3 = Aws::S3::Client.new(region: region)
  File.open(src, 'r') do |io|
    s3.put_object(
      bucket: bucket,
      key: key,
      body: io,
    )
  end
end

def cmd(*args)
  puts "  $ #{args.inspect}"
  system(*args) or raise
end

config_path = ENV.fetch('GUZUTA_YML')
config = YAML.load_file(config_path)

name = config.fetch('name')
region = config.dig('s3', 'region')
bucket = config.dig('s3', 'bucket')
package_key = config.fetch('package_key')
repo_key = config.fetch('repo_key')
arch = ENV.fetch('ARCH', 'aarch64')

pkg_files = Dir.pwd.yield_self do |pwd|
  ARGV.map { |_| File.join(pwd, _) }
end

archdir = File.join(File.dirname(config_path), name, 'os', arch)
FileUtils.mkdir_p archdir
Dir.chdir(archdir) do

  s3_fetch(region, bucket, "#{name}/os/#{arch}/#{name}.files", "#{name}.files", error: false)
  s3_fetch(region, bucket, "#{name}/os/#{arch}/#{name}.db", "#{name}.db", error: false)

  pkg_files.each do |pkg_path|
    puts "==> #{pkg_path}"
    pkg_local_path =   "./#{File.basename(pkg_path)}"
    FileUtils.cp pkg_path, pkg_local_path if File.realpath(pkg_path) != File.realpath(pkg_local_path)
    cmd "gpg2", "--local-user", package_key, "--detach-sign", pkg_local_path
    cmd "guzuta", "files-add", "--repo-key", repo_key, pkg_local_path, "#{name}.files"
    cmd "guzuta", "repo-add", "--repo-key", repo_key, pkg_local_path, "#{name}.db"

    s3_put pkg_local_path, region, bucket, "#{name}/os/#{arch}/#{File.basename(pkg_path)}"
    s3_put "#{pkg_local_path}.sig", region, bucket, "#{name}/os/#{arch}/#{File.basename(pkg_path)}.sig"
  end

  s3_put "#{name}.files", region, bucket, "#{name}/os/#{arch}/#{name}.files"
  s3_put "#{name}.files.sig", region, bucket, "#{name}/os/#{arch}/#{name}.files.sig"
  s3_put "#{name}.db", region, bucket, "#{name}/os/#{arch}/#{name}.db"
  s3_put "#{name}.db.sig", region, bucket, "#{name}/os/#{arch}/#{name}.db.sig"
end
