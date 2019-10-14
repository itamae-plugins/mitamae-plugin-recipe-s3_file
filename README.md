# mitamae-plugin-recipe-s3\_file

MItamae plugin to reproduce the behavior of https://github.com/adamsb6/s3_file v2.7.0

## Usage

See https://github.com/itamae-kitchen/mitamae/blob/v1.5.6/PLUGINS.md.

Put this repository as `./plugins/mitamae-plugin-recipe-s3_file`,
and execute `mitamae local` where you can find `./plugins` directory.

### Example

```rb
s3_file "/tmp/somefile" do
  remote_path "/my/s3/key"
  bucket "my-s3-bucket"
  aws_access_key_id "mykeyid"
  aws_secret_access_key "mykey"
  s3_url "https://s3.amazonaws.com/bucket"
  owner "me"
  group "mygroup"
  mode "0644"
  action :create
  decryption_key "my SHA256 digest key"
  decrypted_file_checksum "SHA256 hex digest of decrypted file"
end
```

## License

```
Copyright 2012-2013 Brandon Adams and other contributors

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
