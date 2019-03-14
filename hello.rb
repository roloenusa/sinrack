require 'json'
require 'logger'
require 'sinatra'

before do
  request.body.rewind
  @body = {}
  begin
    @body = JSON.parse request.body.read
  rescue
    @body = "NO BODY"
  end
end

get '/' do
  "Hello World!"
end

get '/expose' do
  output = {
    'Headers' => request.env,
    'Params' => params
  }
  output = JSON.pretty_generate(output)
  logger.info(output)
  
  output
end

post '/expose' do
  output = {
    'ENV' => request.env,
    'Params' => params,
    'Body' => @body
  }
  output = JSON.pretty_generate(output)
  logger.info(output)

  output
end

post '/webhook' do
  output = {
    'ENV' => request.env,
    'Params' => params,
    'Body' => @body
  }
  output = JSON.pretty_generate(output)
  logger.info(output)

  response = {
    "ResultCode" => 0,
    "DebugMessage" => "OK"
  }

  if params['code'] do
    response['ResultCode'] = params['code']
  end
  
  if params['debug'] do
    response["DebugMessage"] = params['debug']
  end

  if params['data'] do
    response["Data"] = params['data']
  end

  logger.info("=== Response")
  logger.info(response)

  JSON.generate(response)
end