require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @already_built_response = false
    @params = req.params.merge(route_params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end


  def redirect_to(url)
    raise 'double render error' if already_built_response?
    res['Location'] = url
    res.status = 302
    @already_built_response = true
    session.store_session(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    session.store_session(res)
    raise "double render!" if already_built_response?
    @already_built_response = true
    res.write(content)
    res['Content-Type'] = content_type
  end

  def render(template_name)
    controller_name = self.class.name.underscore
    file_name = "views/#{controller_name}/#{template_name}.html.erb"
    file = File.read(file_name)
    template = ERB.new(file).result(binding)
    render_content(template,'text/html')
  end

  # method exposing a `Session` object
  def session
    @session||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
end
