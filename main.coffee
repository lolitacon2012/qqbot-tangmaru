#!/usr/bin/env coffee
#current_group_name = "2015-SM2-19th全国学生群"
current_group_name = "机器人测试"
log = new (require("log"))("debug")
auth = require("./src/qqauth")
api = require("./src/qqapi")
QQBot = require("./src/qqbot")
defaults = require("./src/defaults")
config = require("./config")
KEY_COOKIES = "qq-cookies"
KEY_AUTH = "qq-auth"
mouth_open = true
stopped = false
fx_firstTime = true
shiliu_firstTime = true
chitanda_firstTime = true
yangming_firstTime = true
actualPersonToRob = undefined
laoban_firstTime = true
king_firstTime = true
popularValue = 0
popularPerson = undefined
mostPopular = undefined
secondPopular = undefined
message_record = []
me_hungry = 500
me_yellow = 20
me_ex = 1000
me_monkey = undefined
me_full = 0
digesting = undefined
members = {}
foods = {}
weapons = {}
dougu = {}
stomach = []
lottery = []
student_group = undefined
kfcCustomers = undefined
not_same_again = true
last_command = ""
last_commander = ""

get_tokens = (isneedlogin, options, callback) ->
  if isneedlogin
    auth.login options, (cookies, auth_info) ->
      defaults.data KEY_COOKIES, cookies
      defaults.data KEY_AUTH, auth_info
      defaults.save()
      callback cookies, auth_info

  else
    cookies = defaults.data(KEY_COOKIES)
    auth_info = defaults.data(KEY_AUTH)
    log.info "skip login"
    callback cookies, auth_info

run = ->
  "start qqbot..."
  params = process.argv.slice(-1)[0] or ""
  isneedlogin = params.trim() isnt "nologin"
  get_tokens isneedlogin, config, (cookies, auth_info) ->
    bot = new QQBot(cookies, auth_info, config)
    bot.on_die ->
      run()  if isneedlogin

    bot.update_all_members (ret) ->
      unless ret
        log.error "获取信息失败"
        process.exit 1
      log.info "Entering runloop, Enjoy!"
      bot.listen_group current_group_name, (_group, error) ->
        log.info "enter long poll mode, have fun"
        bot.runloop()
        student_group = _group
        foods["蛋挞"] = {price: 10, nice: 2, size: 5}
        foods["玉米"] = {price: 5, nice: 1, size: 3}
        foods["鸡块"] = {price: 15, nice: 3, size: 10}
        foods["原味鸡"] = {price: 20, nice: 4, size: 15}
        foods["烤翅"] = {price: 20, nice: 4, size: 12}
        foods["可乐"] = {price: 8, nice: 1, size: 3}
        foods["土豆泥"] = {price: 12, nice: 2, size: 6}
        foods["鸡腿堡"] = {price: 50, nice: 15, size: 20}
        foods["烤鸡腿堡"] = {price: 70, nice: 20, size: 25}
        foods["全家桶"] = {price: 550, nice: 100, size: 100}
        foods["面包"] = {price: 5, nice: 1, size: 3}
        foods["薯条"] = {price: 15, nice: 3, size: 8}
        foods["鸡米花"] = {price: 30, nice: 13, size: 12}
        foods["鸡翅"] = {price: 16, nice: 3, size: 12}
        foods["全虾堡"] = {price: 80, nice: 25, size: 25}
        foods["烤鸡腿堡套餐"] = {price: 110, nice: 35, size: 32}
        foods["鸡腿堡套餐"] = {price: 85, nice: 23, size: 30}
        foods["全虾堡套餐"] = {price: 125, nice: 40, size: 30}
        foods["金坷垃"] = {price: 99999, nice: 99999, size: 1}

        weapons["逻辑"] = {attack: 10, price: 50, once:false, bonus:false }
        weapons["利刃"] = {attack: 100, price: 500, once:false, bonus:false }
        weapons["砍刀"] = {attack: 220, price: 1000, once:false, bonus:false }
        weapons["木棒"] = {attack: 80, price: 400, once:false, bonus:false }
        weapons["铁锤"] = {attack: 160, price: 750, once:false, bonus:false }
        weapons["二踢脚"] = {attack: 550, price: 2500, once:true, bonus:false }
        weapons["AK47"] = {attack: 320, price: 1500, once:false, bonus:false }
        weapons["MP5"] = {attack: 265, price: 1250, once:false, bonus:false }
        weapons["AWP"] = {attack: 880, price: 4000, once:false, bonus:false }
        weapons["M4A1"] = {attack: 444, price: 2000, once:false, bonus:false }
        weapons["氢弹"] = {attack: 6500, price: 25000, once:true, bonus:false }
        weapons["电磁炮"] = {attack: 1400, price: 5000, once:false, bonus:false }
        weapons["野狗"] = {attack: 80, price: 3000, once:false, bonus:false }
        weapons["狼狗"] = {attack: 120, price: 9000, once:false, bonus:false }

        adj = ["恐惧", "超能", "暗黑", "光明", "震撼", "护体", "吸血", "国产", "破碎", "贪婪", "治愈"]

        list_one = bot.groupmember_info[student_group.gid].minfo
        for suspect in list_one
          members[suspect.nick] = { nickname: suspect.nick, nice: 0, objects: ["蛋挞","可乐", "面包","烤翅","逻辑"], gold: 3000, water: 0, life: 1500, firstseen:true}

        bot.request.get {url:"http://api.hitokoto.us/rand",json:true}, (e,r,data)->
          if data and data.hitokoto
            student_group.send "大家好啊，我是男神唐马儒，我能联系到美国肯打鸡、俄国军火商和中国体育彩票，同时我也是专业鉴黄师~\n\n今日名言警句：\n"+data.hitokoto + "\n--" + data.source
            return
          else
            student_group.send "大家好啊，我是男神唐马儒，我家经营肯打鸡，同时我也是专业鉴黄师~。。"
            return
        
        student_group.on_message (content, send, robot, message) ->
          members[message.from_user.nick].water = members[message.from_user.nick].water + 1

          if (content.indexOf("唐马儒？") is 0) is true
            mouth_open = true
            student_group.send "这儿呢"

          if (lottery.length>9)
            lottery_winner = Math.floor(Math.random() * (9 + 1) + 0)
            winner_name = lottery[lottery_winner]
            lottery_winner_second = Math.floor(Math.random() * (8 + 1) + 0)
            winner_name_second = lottery[lottery_winner_second]
            lottery_winner_third = Math.floor(Math.random() * (7 + 1) + 0)
            winner_name_third = lottery[lottery_winner_third]
            members[winner_name].gold = members[winner_name].gold+1200
            members[winner_name_third].gold = members[winner_name_third].gold+600
            members[winner_name_second].gold = members[winner_name_second].gold+600
            student_group.send "【彩票开奖】\n\n恭喜"+members[winner_name].nickname+"获得一等奖1500新币！！！\n\n"+"恭喜"+members[winner_name_second].nickname+"和"+members[winner_name_third].nickname+"获得二等奖600新币！"
            lottery = []

          if (last_command is content) and (last_commander is message.from_user.nick)
            not_same_again = false
          else
            not_same_again = true
            last_command = content
            last_commander = message.from_user.nick

          if ((mouth_open) is true) and ((not_same_again) is true)

            if (content.indexOf("唐马儒状态") is 0) is true
              student_group.send "鉴黄力："+me_yellow+"\n饱腹感："+me_full+"%\n和谁生猴子："+me_monkey

            if (content.indexOf("唐马儒叫我") is 0) is true
              toNick = content.substring(content.indexOf("我")+1)
              
              if (toNick.length > 0)
                can_use = true

                for suspect in list_one
                  if (members[suspect.nick].nickname is toNick) is true
                    student_group.send toNick+"这个名字已经被占了，不能用"
                    can_use = false
                    break
                if can_use is true
                  if ((toNick is "唐马儒") or (toNick is "肯打鸡")) is true
                    student_group.send "想作死请去打劫唐马儒，别自己改名叫唐马儒。"
                  else
                    if (toNick.length > 10)
                      student_group.send "名字太长！"
                    else
                      student_group.send "玩家"+message.from_user.nick+"更名为"+toNick
                      members[message.from_user.nick].nickname = toNick
                

            if (content.indexOf("肯打鸡购买") is 0) is true
              toBuy = content.indexOf("买")
              thingToBuy = content.substring(toBuy+1)
              if (thingToBuy of foods) is true
                if (members[message.from_user.nick].gold >= foods[thingToBuy].price) is true
                  student_group.send members[message.from_user.nick].nickname+"购买"+thingToBuy+"，消费"+foods[thingToBuy].price+"新币！"
                  members[message.from_user.nick].objects.push thingToBuy
                  members[message.from_user.nick].gold = members[message.from_user.nick].gold - foods[thingToBuy].price
                else
                  student_group.send members[message.from_user.nick].nickname+"你个穷鬼也想买"+thingToBuy+"？你有"+foods[thingToBuy].price+"新币么？"

            if (content.indexOf("购买彩票") is 0) is true
              if (members[message.from_user.nick].gold >= 400) is true
                student_group.send members[message.from_user.nick].nickname+"购买彩票一张，消费400新币！祝您中奖！"
                members[message.from_user.nick].objects.push
                members[message.from_user.nick].gold = members[message.from_user.nick].gold - 400
                lottery.push message.from_user.nick
              else
                student_group.send members[message.from_user.nick].nickname+"，你没钱还敢来买彩票？"

            if (content.indexOf("军火商购买") is 0) is true
              toBuy = content.indexOf("买")
              thingToBuy = content.substring(toBuy+1)
              if (thingToBuy of weapons) is true
                if (members[message.from_user.nick].gold >= weapons[thingToBuy].price) is true

                  randomnumberone = Math.floor(Math.random() * (4 + 1) + 0)
                  randomnumbertwo = 5 + Math.floor(Math.random() * (5 + 1) + 0)
                  weaponResult = adj[randomnumberone]+"之"+adj[randomnumbertwo]+"的"+thingToBuy
                  student_group.send members[message.from_user.nick].nickname+"购买到了"+weaponResult+"，消费"+weapons[thingToBuy].price+"新币！"
                  members[message.from_user.nick].objects.push weaponResult
                  members[message.from_user.nick].gold = members[message.from_user.nick].gold - weapons[thingToBuy].price
                else
                  student_group.send members[message.from_user.nick].nickname+"买"+thingToBuy+"需要"+weapons[thingToBuy].price+"新币，没钱滚粗"

            if ((content.indexOf("用") is 0) and (content.indexOf("攻击")>0)) is true
              toRob = content.indexOf("击")
              personToRob = content.substring(toRob+1)
              usedWeapon = content.substring(content.indexOf("用")+1,toRob-1)
              has_personToRob = false

              for suspect in list_one
                if(members[suspect.nick].nickname is personToRob)
                  has_personToRob = true
                  actualPersonToRob = suspect.nick
                  break

              if ((usedWeapon in members[message.from_user.nick].objects) and (has_personToRob)) is true
                if ((personToRob) is "唐马儒") or ((personToRob) is "肯打鸡")
                  student_group.send members[message.from_user.nick].nickname+"作死抢劫"+personToRob+"失败，唐马儒非常伤心。好感度下降50。"
                  members[message.from_user.nick].nice = members[message.from_user.nick].nice-50

                else
                  actual_weapon = usedWeapon.substring(usedWeapon.indexOf("的")+1)
                  actual_damage = weapons[actual_weapon].attack
                  rob_damage = 0
                  rob_gold = 0
                  disappear = false
                  get_life = 0
                  self_damage = actual_damage*0.5
                  if (usedWeapon.indexOf("恐惧")>=0)
                    rob_damage = rob_damage + 20
                  if (usedWeapon.indexOf("超能")>=0)
                    rob_damage = rob_damage + actual_damage
                  if (usedWeapon.indexOf("暗黑")>=0)
                    rob_damage = rob_damage + 60
                  if (usedWeapon.indexOf("光明")>=0)
                    self_damage = 0
                  if (usedWeapon.indexOf("震撼")>=0)
                    self_damage = self_damage*1.5
                    rob_damage = rob_damage + actual_damage + actual_damage
                  if (usedWeapon.indexOf("护体")>=0)
                    self_damage = self_damage*0.1
                  if (usedWeapon.indexOf("吸血")>=0)
                    get_life = actual_damage
                  if (usedWeapon.indexOf("国产")>=0)
                    self_damage = actual_damage*1.5
                  if (usedWeapon.indexOf("破碎")>=0)
                    disappear = true
                  if (usedWeapon.indexOf("贪婪")>=0)
                    rob_gold = actual_damage + rob_damage
                  if (usedWeapon.indexOf("治愈")>=0)
                    rob_damage = 0-actual_damage
                  
                  actual_damage = actual_damage + rob_damage
                  if (members[actualPersonToRob].gold <= 0) is true
                    rob_gold = 0
                  members[message.from_user.nick].life = members[message.from_user.nick].life - self_damage + get_life
                  members[message.from_user.nick].gold = members[message.from_user.nick].gold + rob_gold
                  dissappear_ran = Math.floor(Math.random() * (100 + 1) + 0)
                  dissappear_to_say = ""
                  if ((disappear) or (dissappear_ran > 90)) 
                    dissappear_to_say = "武器受到严重损坏并丢弃！"
                    members[message.from_user.nick].objects.splice(members[message.from_user.nick].objects.indexOf(usedWeapon), 1)

                  members[actualPersonToRob].life = members[actualPersonToRob].life - actual_damage
                  members[actualPersonToRob].gold = members[actualPersonToRob].gold - rob_gold

                student_group.send members[message.from_user.nick].nickname+"使用"+usedWeapon+"袭击了"+personToRob+"，造成"+actual_damage+"伤害并抢夺了"+rob_gold+"新币！"+members[message.from_user.nick].nickname+"在战斗中自身受到"+self_damage+"伤害！"+dissappear_to_say
                if(members[actualPersonToRob].life <= 0)
                  student_group.send members[actualPersonToRob].nickname+"被"+members[message.from_user.nick].nickname+"残忍的杀害了！"
            if (content.indexOf("查看我的状态") is 0) is true
              things_to_show = ""
              for itemz in members[message.from_user.nick].objects
                things_to_show = things_to_show + itemz + "　"
              student_group.send "【玩家"+message.from_user.nick+"（"+members[message.from_user.nick].nickname+"）】\n生命："+members[message.from_user.nick].life+"\n新币："+members[message.from_user.nick].gold+"\n水度："+members[message.from_user.nick].water+"\n好感："+members[message.from_user.nick].nice+"\n物品："+things_to_show

            if (content.indexOf("唐马儒吃") is 0) is true
              toEat = content.indexOf("吃")
              food = content.substring(toEat+1)

              if ((toEat>1) and (me_full<91)) is true
                if ((food in members[message.from_user.nick].objects) and (food of foods)) is true
                  student_group.send "我吃了"+members[message.from_user.nick].nickname+"给的"+food+"，鉴黄力 +"+foods[food].price+"，对玩家好感度 +"+foods[food].nice+"！"
                  me_yellow = me_yellow + foods[food].price
                  me_full = me_full + foods[food].size
                  members[message.from_user.nick].nice = members[message.from_user.nick].nice+foods[food].nice
                  stomach.push members[message.from_user.nick].nickname+"的"+food
                  members[message.from_user.nick].objects.splice(members[message.from_user.nick].objects.indexOf(food), 1)
                else
                  if (food of foods) is true
                    student_group.send "你没有"+food+"，请光临肯打鸡购买！"
                  else
                    student_group.send "这东西不能吃！"
              else
                if (me_full>90) is true
                  student_group.send "我吃饱了！想上厕所！！！"

            if (content.indexOf("吃") is 0) is true
              toEat = content.indexOf("吃")
              food = content.substring(toEat+1)
              if ((food in members[message.from_user.nick].objects) and (food of foods)) is true
                student_group.send members[message.from_user.nick].nickname+"食用了一份"+food+"，回复"+(foods[food].price+30)+"生命值！"
                members[message.from_user.nick].life = members[message.from_user.nick].life + foods[food].price+30
                members[message.from_user.nick].objects.splice(members[message.from_user.nick].objects.indexOf(food), 1)
              else
                if (food of foods) is true
                  student_group.send "你没有"+food+"，请光临肯打鸡购买！"
                else
                  student_group.send "这东西不能吃！"

            if (content.indexOf("出售") is 0) is true
              toThrow = content.indexOf("售")
              laji = content.substring(toThrow+1)
              if (laji in members[message.from_user.nick].objects) is true
                student_group.send members[message.from_user.nick].nickname+"出售了"+laji+"，换回50新币"
                members[message.from_user.nick].gold = members[message.from_user.nick].gold+50
                members[message.from_user.nick].objects.splice(members[message.from_user.nick].objects.indexOf(laji), 1)
              else
                if ((laji of foods) or (laji of weapons)) is true
                  student_group.send "你没有"+laji+"，请光临肯打鸡或者军火商购买！"
                else
                  student_group.send "你在说什么？。。"

            if (content.indexOf("唐马儒上厕所") is 0) is true
              if (stomach.length>0) is true
                toPull = "卧槽憋不住了。。。噗！！！！！\n消化掉"
                for shit in stomach
                  me_hungry = me_hungry - 4
                  toPull = toPull + shit + "，"
                toPull = toPull + "尼玛现在我又想吃东西了！"
                me_full = 0;
                student_group.send toPull
                stomach = []
              else
                student_group.send "我肚子里什么都没有，赶紧给我吃东西！"

            if (content.indexOf("notused@唐马儒开始鉴黄") is 0) is true

              suspectToSend = "【鉴黄结果】"+ "\n" + "以下账号同时存在于家长群和学生群："+"\n"
              list_one = robot.groupmember_info[student_group.gid].minfo
              list_two = robot.groupmember_info[target_group.gid].minfo
              for suspect in list_one
                for c_suspect in list_two
                 if (c_suspect.nick is suspect.nick) is true
                  suspectToSend = suspectToSend  + "\n" + suspect.nick
              
              student_group.send suspectToSend + "\n" + "请管理员清理（别清理我）" + "\n" + "另据可靠消息，该群存在家长使用学生号的现象。今天下午家长群得到的消息就是这么泄露的。" + "\n"+"管理员呢？"
            
            if (content.indexOf("唐马儒闭嘴") is 0) is true
              mouth_open = false
              student_group.send "艹。。"

            if (message.from_user.nick is "江城") is true
              if fx_firstTime
                student_group.send "函数！你好吖！我代学娘向你问好！祝你今天开心！"
              fx_firstTime = false

            if (message.from_user.nick is "我是一颗大石榴") is true
              if shiliu_firstTime
                student_group.send "石榴妹子你好吖~！祝你今天也萌萌哒~"
              shiliu_firstTime = false

            if (message.from_user.nick is "柳落梨花雨") is true
              if chitanda_firstTime
                student_group.send "吃蛋挞我要吃！了！你！吃了你！好萌！！！"
              chitanda_firstTime = false

            if (message.from_user.nick is "Fantastic Me") is true
              if laoban_firstTime
                student_group.send "哇～～快看～～老板来啦～～"
              laoban_firstTime = false

            if (message.from_user.nick is "NERvGear•炀名") is true
              if yangming_firstTime
                student_group.send "炀名泥嚎。。"
              yangming_firstTime = false

            if (message.from_user.nick is "😊👊Perseverance😊") is true
              if king_firstTime
                student_group.send "King萬福金安！"
              king_firstTime = false

            if (content.indexOf("notused@唐马儒现在测试群说什么？") is 0) is true
              total_message = message_record.length
              if (total_message<1) is true
                student_group.send "他们啥也没说啊"
                return
              toSend = "【家长群】"
              for element in message_record
                toSend = toSend  + "\n" + element
              message_record = []
              student_group.send toSend
              toSend = undefined

            if (content.indexOf("唐马儒名言警句") is 0) is true
              data = undefined
              robot.request.get {url:"http://api.hitokoto.us/rand",json:true}, (e,r,data)->      
                if data and data.hitokoto
                  student_group.send data.hitokoto + "--" + data.source
                else
                  student_group.send e
              return
        return 

      target_group = undefined

run()
