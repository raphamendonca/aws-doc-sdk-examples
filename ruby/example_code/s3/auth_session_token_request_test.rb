#**
 #* Copyright 2010-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 #*
 #* This file is licensed under the Apache License, Version 2.0 (the "License").
 #* You may not use this file except in compliance with the License. A copy of
 #* the License is located at
 #*
 #* http://aws.amazon.com/apache2.0/
 #*
 #* This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 #* CONDITIONS OF ANY KIND, either express or implied. See the License for the
 #* specific language governing permissions and limitations under the License.
#**


# snippet-sourcedescription:[auth_session_token_request_test.rb creates a temporary user to list the items in a specified bucket for one hour. To use this example, you must have AWS credentials that have the necessary permissions to create new AWS Security Token Service (AWS STS) clients, and list Amaazon S3 buckets using temporary security credentials] 
# snippet-service:[s3]
# snippet-keyword:[Ruby]
# snippet-keyword:[Amazon S3]
# snippet-keyword:[Code Sample]
# snippet-keyword:[PUT Bucket]
# snippet-sourcetype:[full-example]
# snippet-sourcedate:[2019-01-28]
# snippet-sourceauthor:[AWS]

# snippet-start:[s3.ruby.auth_session_token_request_test.rb]

# This snippet example does the following:
# The following Ruby example creates a temporary user to list the items in a specified bucket
# for one hour. To use this example, you must have AWS credentials that have the necessary
# permissions to create new AWS Security Token Service (AWS STS) clients, and list Amaazon S3 buckets using temporary security credentials 
# using your AWS account security credentials, the temporary security credentials are valid for only one hour. You can
# specify session duration only if you use &IAM; user credentials to request a session.

require 'aws-sdk-core'
require 'aws-sdk-s3'
require 'aws-sdk-iam'


USAGE = <<DOC

Usage: assumerole_create_bucket_policy.rb -b BUCKET -u USER [-r REGION] [-d] [-h]

  Assumes a role for USER to list items in BUCKET for one hour.

  BUCKET is required and must already exist.

  USER is required and if not found, is created.

  If REGION is not supplied, defaults to us-west-2.

  -d gives you extra (debugging) information.

  -h displays this message and quits.

DOC

$debug = false

def print_debug(s)
  if $debug
    puts s
  end
end

def get_user(region, user_name, create)
  user = nil
  iam = Aws::IAM::Client.new(region: 'us-west-2')
  
begin
  user = iam.create_user(user_name: user_name)
  iam.wait_until(:user_exists, user_name: user_name)
  print_debug("Created new user #{user_name}")
rescue Aws::IAM::Errors::EntityAlreadyExists
  print_debug("Found user #{user_name} in region #{region}")
end
end

# main
region = 'us-west-2'
user_name = ''
bucket_name = ''

i = 0

while i &lt; ARGV.length
  case ARGV[i]

    when '-b'
      i += 1
      bucket_name = ARGV[i]

    when '-u'
      i += 1
      user_name = ARGV[i]

    when '-r'
      i += 1

      region = ARGV[i]

    when '-d'
      puts 'Debugging enabled'
      $debug = true

    when '-h'
      puts USAGE
      exit 0

    else
      puts 'Unrecognized option: ' + ARGV[i]
      puts USAGE
      exit 1

  end

  i += 1
end

if bucket_name == ''
  puts 'You must supply a bucket name'
  puts USAGE
  exit 1
end

if user_name == ''
  puts 'You must supply a user name'
  puts USAGE
  exit 1
end

#Identify the IAM user that is allowed to list Amazon S3 bucket items for an hour.
user = get_user(region, user_name, true)

# Create a new Amazon STS client and get temporary credentials. This uses a role that was already created.
creds = Aws::AssumeRoleCredentials.new(
  client: Aws::STS::Client.new(region: region),
  role_arn: "arn:aws:iam::111122223333:role/assumedrolelist",
  role_session_name: "assumerole-s3-list"
)

# Create an Amazon S3 resource with temporary credentials.
s3 = Aws::S3::Resource.new(region: region, credentials: creds)

puts "Contents of '%s':" % bucket_name
puts '  Name => GUID'

 s3.bucket(bucket_name).objects.limit(50).each do |obj|
      puts "  #{obj.key} => #{obj.etag}"
end
# snippet-end:[s3.ruby.auth_session_token_request_test.rb]