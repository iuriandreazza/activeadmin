module ActiveAdmin
  module Views
    module Pages
      class Base < Arbre::HTML::Document

        def build(*args)
          super
          add_classes_to_body
          build_active_admin_head
          build_page
        end

        private

        def add_classes_to_body
          # @body.add_class(params[:action])
          # @body.add_class(params[:controller].tr('/', '_'))
          # @body.add_class("active_admin")
          # @body.add_class("logged_in")
          # @body.add_class(active_admin_namespace.name.to_s + "_namespace")
        end

        def build_active_admin_head
          within @head do
            insert_tag Arbre::HTML::Title, [title, render_or_call_method_or_proc_on(self, active_admin_namespace.site_title)].compact.join(" | ")
            meta(:name => "viewport", :content => "width=device-width, initial-scale=1.0")
            active_admin_application.stylesheets.each do |style, options|
              text_node stylesheet_link_tag(style, options).html_safe
            end

            active_admin_application.javascripts.each do |path|
              text_node(javascript_include_tag(path))
            end

            if active_admin_namespace.favicon
              text_node(favicon_link_tag(active_admin_namespace.favicon))
            end

            active_admin_namespace.meta_tags.each do |name, content|
              text_node(tag(:meta, name: name, content: content))
            end

            text_node csrf_meta_tag
          end
        end

        def build_page
          within @body do
            section id: "container" do
              build_unsupported_browser
              if !(active_admin_namespace.unsupported_browser_matcher =~ request.user_agent)
                build_header
                build_menu
                build_page_content
                build_footer
              end
            end
          end
        end

        def build_unsupported_browser
          if active_admin_namespace.unsupported_browser_matcher =~ request.user_agent
            insert_tag view_factory.unsupported_browser
          end
        end

        def build_header
          insert_tag view_factory.header, active_admin_namespace, current_menu
        end

        def build_title_bar
          header class: 'panel-heading wht-bg col-sm-12' do
            insert_tag view_factory.title_bar, title, action_items_for_action
          end
        end

        def build_menu
          aside do
            div(class:"nav-collapse", id:"sidebar")do
              div(class:"leftside-navigation")do
                insert_tag view_factory.global_navigation, current_menu, class: 'sidebar-menu', id: 'nav-accordion'
              end
            end
          end
        end

        def build_page_content
          section id: "main-content", class: (skip_sidebar? ? "without_sidebar" : "with_sidebar") do
            build_main_content_wrapper
            # build_sidebar unless skip_sidebar?
          end
        end

        def build_flash_messages
          flash_messages.each do |type, message|
            div class: "alert alert-#{type} alert-block fade in" do
              button class: "close close-sm", "data-dismiss" => type do
                i class: "fa fa-times"
              end
              strong do
                text_node type
              end
              text_node message
            end
          end
        end

        def build_main_content_wrapper
          section class: "wrapper" do
            div class: "row" do
              div do |d|
                if !skip_sidebar?
                  d.add_class "col-sm-9"
                else
                  d.add_class "col-sm-12"
                end
                section class: "panel" do
                  build_breadcrumb
                end
                section class: "panel col-sm-12" do
                  build_title_bar
                  build_flash_messages
                  div class: "panel-body minimal col-sm-12" do
                    main_content
                  end
                end
              end
              if !skip_sidebar?
                build_sidebar
              end
            end
          end
          text_node(javascript_include_tag('admin/bottom'))
          text_node(javascript_include_tag('//cdnjs.cloudflare.com/ajax/libs/jquery-easing/1.3/jquery.easing.min.js'))
          text_node(javascript_include_tag('//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.5.2/underscore-min.js'))

        end

        def main_content
              I18n.t('active_admin.main_content', model: title).html_safe
        end

        def title
          self.class.name
        end

        def build_breadcrumb(separator = "/")
          breadcrumb_config = active_admin_config && active_admin_config.breadcrumb

          links = if breadcrumb_config.is_a?(Proc)
                    instance_exec(controller, &active_admin_config.breadcrumb)
                  elsif breadcrumb_config.present?
                    breadcrumb_links
                  end
          return unless links.present? && links.is_a?(::Array)
          ul class: "breadcrumb" do
            links.each do |link|
              li do
                  text_node link
              end
            end
            # links.each do |link|
            #   text_node link
            #   span(separator, class: "breadcrumb_sep")
            # end
          end
        end

        # Set's the page title for the layout to render
        def set_page_title
          set_ivar_on_view "@page_title", title
        end

        # Returns the sidebar sections to render for the current action
        def sidebar_sections_for_action
          if active_admin_config && active_admin_config.sidebar_sections?
            active_admin_config.sidebar_sections_for(params[:action], self)
          else
            []
          end
        end

        def action_items_for_action
          if active_admin_config && active_admin_config.action_items?
            active_admin_config.action_items_for(params[:action], self)
          else
            []
          end
        end

        # Renders the sidebar
        def build_sidebar
          div class: 'col-sm-3' do
            sidebar_sections_for_action.collect do |section|
              sidebar_section(section)
            end
          end
        end

        def skip_sidebar?
          sidebar_sections_for_action.empty? || assigns[:skip_sidebar] == true
        end

        # Renders the content for the footer
        def build_footer
          insert_tag view_factory.footer
        end

      end
    end
  end
end