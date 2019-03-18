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

def generateResponse(response)
  logger.info("=== Response")
  logger.info(response)

  JSON.generate(response)
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

  if params['code'] then
    response['ResultCode'] = params['code']
  end
  
  if params['debug'] then
    response["DebugMessage"] = params['debug']
  end

  if params['data'] then
    response["Data"] = params['data']
  end

  response['data'] = {
    'dataKey' => 'dataValue',
    'dataKey2' => @body.dig('Message', 'dataMessage')
  }

  generateResponse(response)
end

post '/webhook/destroy' do
  output = {
    'ENV' => request.env,
    'Params' => params,
    'Body' => @body
  }
  output = JSON.pretty_generate(output)
  logger.info(output)

  response = {
    "ResultCode" => 0,
  }

  if File.exists?("binaryHistory.txt") then
    file = File.open('binaryHistory.txt', 'w')
  else
    file = File.new("binaryHistory.txt", 'w')
  end

  if bh = @body.dig('ChannelState', 'BinaryHistory') then
    file.puts(bh)
  end
  file.close

  generateResponse(response)
end

post '/webhook/create' do
  output = {
    'ENV' => request.env,
    'Params' => params,
    'Body' => @body
  }
  output = JSON.pretty_generate(output)
  logger.info(output)

  response = {
    "ResultCode" => 0,
    "ChannelState" => {}
  }

  if File.exists?("binaryHistory.txt") then
    file = File.open('binaryHistory.txt', 'r')
    response['ChannelState']['BinaryHistory'] = file.read
  end

  generateResponse(response)
end

