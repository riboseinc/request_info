require "action_dispatch/middleware/stack"

RSpec.shared_context "test stack" do
  let(:inner_app) do
    lambda do |env|
      expect(env).to be_a(Hash)
      [200, {"Custom-Header" => "Yes"}, ["Hello World"]]
    end
  end

  let(:rack_stack_builder) do
    builder = ActionDispatch::MiddlewareStack.new
    builder.use RequestInfo::DetectorApp
    builder
  end

  let(:app) { rack_stack_builder.build(inner_app) }
  let(:mock_request) { Rack::MockRequest.new(app) }

  def expectations_on_inner_app
    allow(inner_app).to receive(:call).and_wrap_original do |m, env|
      yield(env)
      m.call(env)
    end
  end

  def make_request(env)
    mock_response = mock_request.request(:get, "/", env)
    expect(mock_response.status).to be(200)
    expect(mock_response.body).to eq("Hello World")
    expect(mock_response.headers).to include("Custom-Header" => "Yes")
    mock_response
  end
end
