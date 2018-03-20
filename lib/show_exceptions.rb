require 'erb'

class ShowExceptions
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
    app.call(env)
    rescue Exception => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    res = Rack::Response.new()
    read_file = File.read('/lib/templates/rescue.html.erb')
    erb_template = ERB.new(read_file).result(binding)
    res.write(erb_template)
    res.status = 500
    res['Content Type'] = 'text/html'
    res.finish
  end

end
