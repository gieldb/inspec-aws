# frozen_string_literal: true

require 'aws_backend'

class AwsKinesis < AwsResourceBase
  name 'aws_kinesis'
  desc 'Verifies settings for a Kinesis stream'

  example "
    describe aws_kinesis('kinesis_stream_name_1') do
      it { should exist }
    end
  "

  attr_reader :stream_name, :stream_arn, :stream_status, :retention_period_hours,
              :stream_creation_timestamp, :encryption_type, :open_shard_count,
              :consumer_count

  def initialize(opts = {})
    opts = { stream_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: [:stream_name])

    catch_aws_errors do
      begin
        resp = @aws.kinesis_client.describe_stream(stream_name: opts[:stream_name])
        @stream = resp.stream_description.to_h
        create_resource_methods(@stream)
      rescue Aws::Kinesis::Errors::NotFound
        return
      end
    end
  end

  def exists?
    !@stream.nil? && !@stream.empty?
  end

  def to_s
    "AWS Kinesis #{@stream['stream_name']}"
  end
end
