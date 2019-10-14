define(
  :s3_file,
  remote_path: nil,
  aws_access_key_id: nil,
  aws_secret_access_key: nil,
  token: nil,
  decryption_key: nil,
  path: nil,
  decrypted_file_checksum: nil,
  bucket: nil,
  s3_url: nil,
  owner: nil,
  group: nil,
  mode: nil,
) do
  execute 'echo hello'
end
