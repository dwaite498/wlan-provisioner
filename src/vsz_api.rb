require 'http'
require 'json'


class VSZApi
    attr_reader :base_uri_string
    
    def initialize(host)
        @base_uri_string = "https://#{host}:7443/api/public/"
    end
    
    def uri(path)
        base_uri_string + path
    end
    
    def logon(username, password)
        response = HTTP.post(uri('v4_0/session'), json: {username: username, password: password}) 
        response.body == 200
    end
    
    # returns id of created wlan upon success
    # returns nil if there's an error
    def create_wlan(zone_id, name, ssid, throughController)
        response = HTTP.post(uri("/v5_0/rkszones/#{zone_id}/wlans/standardmac"), json: {
            name: name,
            ssid: ssid,
            # (?) hessid: hessid,
            authServiceOrProfile: {
                throughController: throughController,
                # (?) id: id,
                # (?) name: name,
                # (?) locationDeliveryEnabled: locationDeliveryEnabled
            }
        })
        if response.code != 201
            return nil
        end
        body_string = response.body.to_s
        JSON.parse(body_string)['id']
    end
end