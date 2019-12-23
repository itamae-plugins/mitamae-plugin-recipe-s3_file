module ::S3FileLib
  def self.get_md5_from_s3(bucket, url, path, aws_access_key_id, aws_secret_access_key, token, region = nil)
    aws_cli_env = {'AWS_ACCESS_KEY_ID' => aws_access_key_id, 'AWS_SECRET_ACCESS_KEY' => aws_secret_access_key}
    key = path.sub(/\A\//, '')
    out, _err, status = with_env(aws_cli_env) do
      Open3.capture3('aws', 's3api', 'head-object', '--bucket', bucket, '--key', key)
    end
    if status.success? && !out.empty?
      JSON.parse(out)['Metadata']['md5']
    else
      nil # return nil to always download
    end
  end

  def self.get_from_s3(bucket, _url, path, aws_access_key_id, aws_secret_access_key, _token, region = nil, outfile:)
    aws_cli_env = {'AWS_ACCESS_KEY_ID' => aws_access_key_id, 'AWS_SECRET_ACCESS_KEY' => aws_secret_access_key}
    key = path.sub(/\A\//, '')
    out, err, status = with_env(aws_cli_env) do
      Open3.capture3(
        'aws', 's3api', 'get-object', '--bucket', bucket, '--key', key, outfile
      )
    end
    unless status.success?
      raise "Failed to execute `aws s3api get-object --bucket #{bucket} --key #{key} #{outfile}`:\nstdout:\n```\n#{out}```\nstderr:\n```\n#{err}```"
    end
  end

  def self.verify_md5_checksum(checksum, file)
    local_file_md5sum = ::IO.popen("md5sum #{file.shellescape}") do |io|
      io.read.split(/\s+/).first
    end
    checksum == local_file_md5sum
  end

  # mruby's Open3.capture3 does not take the optional env argument yet. This is a workaround for it.
  class << self
    private def with_env(env, &block)
      orig = {}
      env.each do |key, value|
        orig[key] = ENV[key]
        ENV[key] = value
      end
      block.call
    ensure
      orig.each do |key, value|
        ENV[key] = value
      end
    end
  end
end

# https://github.com/adamsb6/s3_file/blob/v2.7/resources/default.rb
define(
  :s3_file,
  # name: nil, (path)
  remote_path: nil,
  bucket: nil,
  aws_access_key_id: nil,
  aws_secret_access_key: nil,
  s3_url: nil, # ignored actually
  token: nil, # ignored actually
  owner: nil,
  group: nil,
  mode: nil,
  decryption_key: nil,
  decrypted_file_checksum: nil,
) do # action :create https://github.com/adamsb6/s3_file/blob/v2.7/providers/default.rb
  download = true

  # handle key specified without leading slash
  remote_path = ::File.join('', params[:remote_path])

  # we need credentials to be mutable
  aws_access_key_id = params[:aws_access_key_id]
  aws_secret_access_key = params[:aws_secret_access_key]
  token = params[:token]
  decryption_key = params[:decryption_key]

  # if credentials not set, try instance profile
  if aws_access_key_id.nil? && aws_secret_access_key.nil? && token.nil?
    # TODO: support this
    raise NotImplementedError, "aws_access_key_id/aws_secret_access_key attributes are nil in s3_file[#{params[:name]}]"
  end

  s3_path = params[:name]
  if ::File.exists?(s3_path)
    if decryption_key.nil?
      if params[:decrypted_file_checksum].nil?
        s3_md5 = S3FileLib.get_md5_from_s3(params[:bucket], params[:s3_url], remote_path, aws_access_key_id, aws_secret_access_key, token)

        if S3FileLib.verify_md5_checksum(s3_md5, s3_path)
          MItamae.logger.debug 'Skipping download, md5sum of local file matches file in S3.'
          download = false
        end
      #we have a decryption key so we must switch to the sha256 checksum
      else
        # TODO: support this
        raise NotImplementedError, "decrypted_file_checksum attribute is not supported by s3_file[#{params[:name]}]"
      end
      # since our resource is a decrypted file, we must use the
      # checksum provided by the resource to compare to the local file
    else
      # TODO: support this
      raise NotImplementedError, "decryption_key attribute is not supported by s3_file[#{params[:name]}]"
    end
  end

  if download
    bucket = params[:bucket]
    s3_url = params[:s3_url]
    # Using `local_ruby_block` to avoid putting it on the recipe evaluation phase.
    local_ruby_block "s3_file[#{s3_path}]" do
      block do
        S3FileLib.get_from_s3(bucket, s3_url, remote_path, aws_access_key_id, aws_secret_access_key, token, outfile: s3_path)
      end
    end

    # not simply using the file resource here because we would have to buffer
    # whole file into memory in order to set content this solves
    # https://github.com/adamsb6/s3_file/issues/15
    unless decryption_key.nil?
      # TODO: support this
      raise NotImplementedError, "decryption_key attribute is not supported by s3_file[#{params[:name]}]"
    else
      # Directly put to outfile
    end
  end

  file s3_path do
    action :create
    owner params[:owner] || ENV['user']
    group params[:group] || ENV['user']
    mode params[:mode] || '0644'
  end
end
