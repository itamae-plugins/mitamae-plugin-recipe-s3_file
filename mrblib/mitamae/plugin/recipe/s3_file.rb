module ::S3FileLib
  def self.get_md5_from_s3(*args)
  end

  def self.verify_md5_checksum(*args)
  end

  def self.get_from_s3(*args)
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
  token: nil,
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

  path = params[:name]
  if ::File.exists?(path)
    if decryption_key.nil?
      if params[:decrypted_file_checksum].nil?
        #s3_md5 = S3FileLib::get_md5_from_s3(params[:bucket], params[:s3_url], remote_path, aws_access_key_id, aws_secret_access_key, token)

        #if S3FileLib::verify_md5_checksum(s3_md5, path)
        #  MItamae.logger.debug 'Skipping download, md5sum of local file matches file in S3.'
        #  download = false
        #end
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
    #response = S3FileLib::get_from_s3(params[:bucket], new_resource.s3_url, remote_path, aws_access_key_id, aws_secret_access_key, token)

    # not simply using the file resource here because we would have to buffer
    # whole file into memory in order to set content this solves
    # https://github.com/adamsb6/s3_file/issues/15
    unless decryption_key.nil?
      # TODO: support this
      raise NotImplementedError, "decryption_key attribute is not supported by s3_file[#{params[:name]}]"
    else
      #::FileUtils.mv(response.file.path, path)
    end
  end

  file path do
    action :create
    owner params[:owner] || ENV['user']
    group params[:group] || ENV['user']
    mode params[:mode] || '0644'
  end
end
