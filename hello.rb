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
  files = {}
  Dir.entries(".").each do |f|
    files[f] = File.stat(f).size
  end
  "Hello World!" + 
  "Dir: " + __dir__ +
  JSON.pretty_generate(files)
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
    # 'ENV' => request.env,
    'Params' => params,
    'Body' => @body
  }
  output = JSON.pretty_generate(output)
  logger.info(output)

  response = {
    "ResultCode" => 0,
  }

  fileName = "binaryHistory#{@body['ChannelName']}.txt"
  file = File.new(fileName, 'w')
  if bh = @body.dig('ChannelState', 'BinaryHistory') then
    logger.info("#{fileName}: Writting to file ");
    file.puts(bh)
  end
  file.close

  generateResponse(response)
end

post '/webhook/create' do
  output = {
    # 'ENV' => request.env,
    'Params' => params,
    'Body' => @body
  }
  output = JSON.pretty_generate(output)
  logger.info(output)

  response = {
    "ResultCode" => 0,
    "ChannelState" => {}
  }

  fileName = "binaryHistory#{@body['ChannelName']}.txt"
  if File.exists?(fileName) then
    logger.info("#{fileName}: Reading from file ");
    file = File.open(fileName, 'r')
    response['ChannelState']['BinaryHistory'] = file.read.strip
    response['ChannelState']['ChannelHistoryCapacity'] = 100
  end

  generateResponse(response)
end

