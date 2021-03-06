module Homura
  module LayoutHelper
    def controller_action_full_name
      [params[:controller], params[:action]].join('#')
    end

    def page_classes
      [params[:controller].gsub('/', '_'), params[:action]].join(' ')
    end

    def page_title(text = nil)
      if text.present?
        @page_title = text
        og_properties title: text
      else
        @page_title
      end
    end

    def page_title_tag
      if @page_title.blank?
        @page_title = controller_action_full_name
        logger.warn "in #{controller_action_full_name}:"
        logger.warn 'No page title specified, please use `page_title` helper.'
      end
      content_tag(:title, t('homura.layout.title', title: @page_title))
    end

    def page_description(text = nil)
      if text.present?
        @page_description = text
        og_properties description: text
      else
        @page_description
      end
    end

    def page_description_tag
      if @page_description.blank?
        logger.warn "in #{controller_action_full_name}:"
        logger.warn 'No page description specified, please use `page_description` helper.'
        return
      else
        tag(:meta, name: :description, content: @page_description)
      end
    end

    # Get/Set canonical link for the page.
    #
    # @raise will raise 'canonical link should be a full url' if not an url
    def canonical_link(url = nil)
      if url
        if url !~ %r(^https?://)
          raise 'canonical link should be a full url'
        else
          @canonical_link = url
        end
      else
        @canonical_link
      end
    end

    def canonical_link_tag
      if @canonical_link.blank?
        logger.warn "in #{controller_action_full_name}:"
        logger.warn 'No canonical link specified, please use `canonical_link` helper.'
        return
      else
        tag(:link, rel: 'canonical_link', href: @canonical_link)
      end
    end

    # Set the Open Graph properties.
    #
    # Examples
    #
    #   og_properties type: 'website',
    #                 image: [image_path('hello.png'),
    #                         image_path('world.png')]
    #
    # the page_title and page_description helpers are also set og properties,
    # so you don't need to do that again.
    def og_properties(properties = {})
      @og_properties ||= {site_name: t('homura.layout.site_name')}
      @og_properties = @og_properties.merge(properties)
    end

    def og_properties_tags
      og_properties.map { |property, content|
        case content
        when Array
          content.map { |item|
            tag(:meta, property: "og:#{property}", content: item)
          }.inject(&:+)
        else
          tag(:meta, property: "og:#{property}", content: content)
        end
      }.inject(&:+)
    end
  end
end
