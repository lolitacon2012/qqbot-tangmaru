###
  外置的插件，以后把唐马儒放到这里
###


module.exports = (content ,send, robot, message)->

  if content.match /^唐马儒自我介绍$/i
    send "大家好啊，我是男神唐马儒，我家经营肯打鸡，同时我也是专业鉴黄师~\n"
  
  if content.match /^die$/i
    robot.die("debug")
    
  if content.match /^reload$/i
    robot.dispatcher.reload_plugin()
    send "重新加载插件"
  
  if content.match /^relogin$/i
    robot.relogin (success)->
      send if success then "成功" else "失败"
  
  # run
  ret = content.match /^run\s+(.*)/i
  if ret
    method = ret[1]
    console.log method
    robot[method]()
  
  # send  
  ret = content.match /^send\s+(.*?)\s+(.*?)\s+(.*)/i
  if ret    
    [type,to,msg] = ret[1..3]
    switch type
      when 'group'
        group = robot.get_group {name:to}
        robot.send_message_to_group group, msg, (ret,e)->
          if e
            send "消息发送失败 #{e}"
          else
            send "消息已发送"
        
      when 'buddy' then ""
      when 'discuss' then ""
      
