module ActiveAdmin
  module Views
    class Header < Component

      def tag_name
        'header'
      end

      def build(namespace, menu)
        super(id: "header", class: "header fixed-top clearfix")

        @namespace = namespace
        @menu = menu
        @utility_menu = @namespace.fetch_menu(:utility_navigation)

        build_site_title
        # build_top_menu
        # build_global_navigation
        build_utility_navigation
      end


      def build_site_title
        insert_tag view_factory.site_title, @namespace
      end

      def build_top_menu

      end

      # def build_global_navigation
      #   insert_tag view_factory.global_navigation, @menu, class: 'header-item tabs'
      # end
      #
      def build_utility_navigation
        div(class:"top-nav clearfix") do
          ul(class:"nav pull-right top-menu") do
            li do
              input(class:"form-control search",placeholder:"Search",name:"search_box_wide")
            end
            # li(class:"dropdown language")do
            #
            # end
            li(class:"dropdown") do
              a({class:"dropdown-toggle", "data-toggle"=>"dropdown"}) do
                if current_active_admin_user.attributes['picture'].nil?
                  img(class: 'default_small_avatar')
                else
                  img(src: current_active_admin_user.attributes['picture'])
                end
                span(class:"username") do
                  display_name current_active_admin_user
                end
                b(class:"caret")
              end
              ul(class:"dropdown-menu extended logout") do
                li do
                  a(href:auto_url_for(current_active_admin_user))do
                    i(class:"fa fa-suitcase")
                    text_node I18n.t 'active_admin.details', model: ''
                  end
                end
                li do
                  a(href:auto_url_for(current_active_admin_user)) do
                    i(class:"fa fa-cog")
                    text_node I18n.t 'active_admin.edit'
                  end
                end
                li do
                  a(href:render_or_call_method_or_proc_on(self, active_admin_namespace.logout_link_path)) do
                    i(class:"fa fa-key")
                    text_node I18n.t 'active_admin.logout'
                  end
                end
              end
            end
            li do
              div(class:"toggle-right-box") do
                div(class:"fa fa-bars")
              end
            end
          end
          insert_tag view_factory.utility_navigation, @utility_menu, id: "utility_nav", class: 'nav pull-right top-menu'
        end
      end

    end
  end
end