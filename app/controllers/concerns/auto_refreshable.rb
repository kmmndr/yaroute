module AutoRefreshable
  extend ActiveSupport::Concern

  included do
    helper_method :auto_refresh
    helper_method :auto_refresh?
  end

  attr_reader :auto_refresh

  def auto_refresh!(delay)
    @auto_refresh = delay
  end

  def auto_refresh?
    !@auto_refresh.nil?
  end
end
