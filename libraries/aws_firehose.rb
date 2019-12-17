# frozen_string_literal: true

require 'aws_backend'

class AwsFirehose < AwsResourceBase
  name 'aws_firehose'
  desc 'Verifies settings for a Kinesis Firehose stream'

  example "
    describe aws_firehose('firehose_name_1') do
      it { should exist }
    end
  "

  attr_reader :delivery_stream_name, :delivery_stream_arn, :delivery_stream_status, :delivery_stream_type,
              :version_id, :create_timestamp, :source, :destinations, :has_more_destinations

  def initialize(opts = {})
    opts = { delivery_stream_name: opts } if opts.is_a?(String)
    super(opts)
    validate_parameters(required: [:delivery_stream_name])

    catch_aws_errors do
      begin
        resp = @aws.kinesis_firehose_client.describe_delivery_stream(delivery_stream_name: opts[:delivery_stream_name])
        @delivery_stream = resp.delivery_stream_description.to_h
        create_resource_methods(@delivery_stream)
      rescue Aws::Firehose::Errors::NotFound
        return
      end
    end
  end

  def exists?
    !@delivery_stream.nil? && !@delivery_stream.empty?
  end

  def to_s
    "AWS Firehose #{@delivery_stream[:delivery_stream_name]}"
  end
end
