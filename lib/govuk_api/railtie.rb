require_relative "middleware/govuk_header_sniffer"

module GovukApi
  class Railtie < Rails::Railtie
    initializer "govuk_api.initialize_govuk_request_id_sniffer" do |app|
      Rails.logger.info "Using middleware GovukApi::GovukHeaderSniffer to sniff for GOVUK-Request-Id header"
      app.middleware.use GovukApi::GovukHeaderSniffer, "HTTP_GOVUK_REQUEST_ID"
    end

    initializer "govuk_api.initialize_govuk_original_url_sniffer" do |app|
      Rails.logger.info "Using middleware GovukApi::GovukHeaderSniffer to sniff for GOVUK-Original-Url header"
      app.middleware.use GovukApi::GovukHeaderSniffer, "HTTP_GOVUK_ORIGINAL_URL"
    end

    initializer "govuk_api.initialize_govuk_authenticated_user_sniffer" do |app|
      Rails.logger.info "Using middleware GovukApi::GovukHeaderSniffer to sniff for X-GOVUK-Authenticated-User header"
      app.middleware.use GovukApi::GovukHeaderSniffer, "HTTP_X_GOVUK_AUTHENTICATED_USER"
    end

    initializer "govuk_api.initialize_govuk_content_id_sniffer" do |app|
      Rails.logger.info "Using middleware GovukApi::GovukHeaderSniffer to sniff for GOVUK-Auth-Bypass-Id header"
      app.middleware.use GovukApi::GovukHeaderSniffer, "HTTP_GOVUK_AUTH_BYPASS_ID"
    end
  end
end
