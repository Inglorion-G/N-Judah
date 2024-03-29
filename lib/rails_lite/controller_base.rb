require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
    @already_build_response = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(body, content_type)
    raise "Already rendered" if already_built_response?
    @res.body, @res.content_type = body, content_type
    if @res.body == body
      @already_built_response = true
    end
    self.session.store_session(@res)
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "Already rendered" if already_built_response?
    @res.status = 302
    @res["Location"] = url
    self.session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template = ERB.new(File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb"))
    b = binding()
    render_content(template.result(b), "text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@res)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_sym)
  end
end
