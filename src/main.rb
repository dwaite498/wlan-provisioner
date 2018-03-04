require "slop"
require_relative "vsz_api.rb"
require "csv"

opts = Slop.parse do |o|
  # o.string '-u', '--username', 'a username', required: true
  # o.string '-p', '--password', 'a password', required: true
  # o.string '-a', '--address', 'the ip address', required: true
  o.string '-c', '--config', 'ap config file', required: true
  o.on '-h', '--help' do
    puts o
    exit
  end
end

puts opts[:username]
puts opts[:password]
puts opts[:address]

api = VSZApi.new(opts[:address])

logonSuccess = api.logon(opts[:username], opts[:password])

if !logonSuccess
  puts "unable to logon"
  exit
end

puts "Logon successful"

# API docs: http://docs.ruckuswireless.com/vscg-enterprise/vsz-e-public-api-reference-guide-3-5.html

# create zone: #ruckus-wireless-ap-zone-create-zone-post
# modify basic: #ruckus-wireless-ap-zone-modify-basic-patch
# create guest wlan: #wlan-create-guest-access-post
# create ethernet port profile: #ethernet-port-profile-create-ethernet-port-porfile-post

zone_id = '' # TODO

CSV.foreach(opts[:config], headers: true, header_converters: [:symbol]) do |r|
  puts 'row'
  puts r[:ap_name]
  puts r[:passphrase]

  # 1. create wlan: #wlan-create-mac-auth-post
  wlan_id = api.create_wlan(zone_id, r[:ap_name], r[:ap_name], false)
  if wlan_id.nil?
    puts 'error creating wlan'
    exit
  end

  # 2. set wlan passphrase: #wlan-modify-encryption-patch
  # 3. create wlan group: #wlan-group-create-post
  # 4. add wlan to group: #wlan-group-add-member-post
  # 5. add guest wlan to group: #wlan-group-add-member-post
end
