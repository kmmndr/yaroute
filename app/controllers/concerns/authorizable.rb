module Authorizable
  extend ActiveSupport::Concern

  included do
    helper_method :abilities, :can?
  end

  protected

  def abilities
    return @abilities unless @abilities.nil?

    @abilities = AbilitiesHandler.new.abilities
  end

  def can?(object, action, subject = nil)
    abilities.allowed?(object, action, subject)
  end

  def forbid
    render plain: 'forbidden', status: :forbidden
  end

  def forbid!
    raise Yaroute::Exceptions::ForbiddenError
  end
end
