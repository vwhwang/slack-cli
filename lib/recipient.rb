require 'httparty'
require 'dotenv'

Dotenv.load 
TOKEN = ENV["SLACK_API_TOKEN"]
USER_TOKEN = ENV["USER_TOKEN"]
BASE_URL = "https://slack.com/api/"
POST_URL = "#{BASE_URL}chat.postMessage"



module SlackCli
  class Recipient

    attr_reader :slack_id, :name

    def initialize(slack_id,name)
      @slack_id = slack_id
      @name = name 
    end

    def self.get(url)
      response = HTTParty.get(url,query:{token:TOKEN})

      if response["ok"] == false || response.code != 200
        raise SlackAPIError, "Error on API #{response["error"]}"
      end 

      return response 
    end 

    def self.list_all
    end 

    def send_msg(message)
      resp = HTTParty.post(POST_URL, {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          token: TOKEN,
          channel: self.slack_id,
          text: message
        }
      })

      if resp.parsed_response["ok"] == false || resp.code != 200
        raise SlackAPIError, "Error on API #{resp["error"]}"
      end 

      return resp.code == 200 && resp.parsed_response["ok"]
    end


    def msg_emoji_name(msg,emoji,name_to_show)
      resp = HTTParty.post(POST_URL, {
        body: {
          token: TOKEN,
          channel: self.slack_id,
          text: msg,
          username: name_to_show,
          icon_emoji: emoji
        }
      })
      return resp.code == 200 && resp.parsed_response["ok"]
    end 

    def show_details
      return self.inspect
    end 

    def show_history
      data = HTTParty.get("https://slack.com/api/conversations.history",query:{
        token:USER_TOKEN,
        channel: self.slack_id
        })
      historys = []
      data["messages"].each do |history|
        historys << history["text"]
      end 
      return historys
    end 


  end
end 


class SlackAPIError < Exception 
end 
