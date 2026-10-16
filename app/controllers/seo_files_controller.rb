class SeoFilesController < ApplicationController
  include SeoHelper

  def robots
    body = <<~TXT
      User-agent: *
      Disallow: /admin/
      Disallow: /en/admin/
      Sitemap: #{canonical_base_url}/sitemap.xml
    TXT
    render plain: body
  end

  def sitemap
    @base = canonical_base_url
    @shops = Shop.visible.order(:id)
    respond_to { |format| format.xml }
  end
end
