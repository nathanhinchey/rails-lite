require_relative './params'
require_relative './session'
require 'active_support'
require 'active_support/core_ext'
require 'erb'

module Phase6
  class ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    attr_reader :req, :res, :params

    # setup the controller
    def initialize(req, res, route_params = {})
      @res = res
      @req = req
      @params = Params.new(req, route_params)
    end

    # Helper method to alias @already_built_response
    def already_built_response?
      !!@already_built_response
    end

    # Populate the response with content.
    # Set the response's content type to the given type.
    # Raise an error if the developer tries to double render.
    def render_content(content, content_type)
      raise "Can't render/redirect twice" if already_built_response?
      res.content_type = content_type
      res.body = content
      session.store_session(res)
      @already_built_response = true
    end

    def render(template_name)
      controller_name = self.class.name.underscore
      f = File.read("views/#{controller_name}/#{template_name}.html.erb")
      render_content(f,'text/html')
    end

    # Set the response status code and header
    def redirect_to(url)
      raise "Can't render/redirect twice" if already_built_response?
      @res["location"]= url
      @res.status = 302
      session.store_session(res)
      @already_built_response = true
    end

    # method exposing a `Session` object
    def session
      @session ||= Session.new(req)
    end

    # use this with the router to call action_name (:index, :show, :create...)
    def invoke_action(name)
      self.send(name)
      render(name) unless already_built_response?
    end
  end
end
