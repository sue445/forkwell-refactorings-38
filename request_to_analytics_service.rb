require "test/unit"
require "mocha/test_unit"

class RequestToAnalyticsService
  def perform(data)
    account           = Account.find(data[:account_id])
    analytics_client  = Analytics::Client.new(Settings.analytics_api_key)

    account_attributes = {
      account_id:         account.id,
      account_name:       account.name,
      account_user_count: account.users.count
    }

    account.users.each do |user|
      analytics_client.request({
        type:  data[:type],
        id:    user.id,
        email: user.email
      }.merge(account_attributes))
    end
  rescue => e
    raise ConnectionFailureException.new(e.message)
  end
end

class ConnectionFailureException < StandardError
end

module Settings
  class << self
    attr_accessor :analytics_api_key
  end
end

class Account
  attr_accessor :id, :name

  def self.find(account_id)
  end

  def users
  end
end

class User
  attr_accessor :id, :email

  def initialize(id, email)
    @id = id
    @email = email
  end
end

module Analytics
  class Client
    def initialize(analytics_api_key)
      @analytics_api_key = analytics_api_key
    end

    def request(data)
    end
  end
end

class RequestToAnalyticsServiceTest < Test::Unit::TestCase
  setup do
    account = Account.new
    users = [
      User.new(3,  "shiny_luminous@max-heart.precure"),
      User.new(8,  "cure_lemonade@yes.precure"),
      User.new(14, "cure_pine@flesh.precure"),
      User.new(18, "cure_sunshine@heart-catch.precure"),
      User.new(23, "cure_muse@suite.precure"),
      User.new(26, "cure_peace@smile.precure"),
      User.new(31, "cure_rosetta@dokidoki.precure"),
      User.new(36, "cure_honey@happiness-charge.precure"),
      User.new(40, "cure_twinkle@go-princess.precure"),
    ]

    account.stubs(:users).returns(users)
    Account.stubs(:find).returns(account)

    @args = { account_id: 1, type: "example" }
  end

  test "performでエラーが起きないこと" do
    RequestToAnalyticsService.new.perform(@args)
  end

  test "perform内でエラーが発生した時にConnectionFailureExceptionが投げられること" do
    Account.stubs(:find).raises(StandardError)

    begin
      RequestToAnalyticsService.new.perform(@args)
      fail "ConnectionFailureExceptionが投げられなかった"
    rescue ConnectionFailureException
    end
  end
end
