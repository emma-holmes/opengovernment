class ApplicationController < ActionController::Base
  include UrlHelper
  helper_method :current_place, :current_place_name, :current_place_subdomain
  before_filter :set_locale

  protect_from_forgery
  
  layout 'application'

  def set_locale
    I18n.locale = extract_locale_from_subdomain
  end

  # Get locale from top-level domain or return nil if such locale is not availabl
  # You have to put something like:
  def extract_locale_from_subdomain
    parsed_locale = request.subdomains.first
    return nil unless parsed_locale
    I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale : nil
  end

  protected
  def resource_not_found
    flash[:error] = "Sorry. We were not able to locate what you were looking for.."
    redirect_to(home_url(:subdomain => false))
  end

  def get_state
    @state = lookup_state(request.subdomain)
    @state || resource_not_found
  end

  def current_place
    @state ||= lookup_state(request.subdomain)
  end

  def current_place_name
    current_place.try(:name)
  end
  
  def current_place_subdomain
    current_place.try(:abbrev).try(:downcase)
  end

  private
  def lookup_state(subdomain)
    return State.find_by_slug(subdomain) || State.find_by_slug(subdomain.sub(/\..*$/,''))
  end
end
