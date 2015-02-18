#!/usr/bin/env ruby
#
# Sensu Handler: delete-hosts
#
# This handler will delete hosts from sensu if they are deleted from stackdio
#
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'net/http'
require 'uri'
require 'json'


class Deleter < Sensu::Handler
  def handle
    params = {
      :stackdio_url      => settings['delete-hosts']['stackdio_url'],
      :stackdio_user     => settings['delete-hosts']['stackdio_user'],
      :stackdio_password => settings['delete-hosts']['stackdio_password']
    }

    host_fqdn = @event['client']['address']

    if @event['check']['status'] > 0
        uri = URI.parse(params[:stackdio_url])

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")

        req = Net::HTTP::Get.new('/api/admin/stacks/')
        req['Accept'] = 'application/json'
        req.basic_auth(params[:stackdio_user], params[:stackdio_password])

        response = http.request(req)

        stacks = JSON.parse(response.body())

        found = false

        stacks['results'].each do |stack|
            req = Net::HTTP::Get.new(stack['fqdns'])
            req['Accept'] = 'application/json'
            req.basic_auth(params[:stackdio_user], params[:stackdio_password])

            response = http.request(req)

            fqdns = JSON.parse(response.body())

            # We found the host, we don't want to delete it
            if fqdns.include? host_fqdn
                found = true
                break
            end
        end

        # We didn't find the fqdn anywhere on stackdio, that means we should delete it on sensu
        if !found
            puts "Deleting host: #{host_fqdn}"

            del_req = api_request(:DELETE, '/clients/' + @event['client']['name'])

            if del_req.code != '202'
                puts 'Sensu delete API call failed'
            else
                puts "Successfully deleted host: #{host_fqdn}"
            end
        end
    end
  end
end
