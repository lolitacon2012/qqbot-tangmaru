var KEY_AUTH, KEY_COOKIES, QQBot, api, auth, config, defaults, get_tokens, log, run;

KEY_AUTH = void 0;

KEY_COOKIES = void 0;

QQBot = void 0;

api = void 0;

auth = void 0;

config = void 0;

defaults = void 0;

get_tokens = void 0;

log = void 0;

run = void 0;

KEY_AUTH = void 0;

KEY_COOKIES = void 0;

QQBot = void 0;

api = void 0;

auth = void 0;

config = void 0;

defaults = void 0;

get_tokens = void 0;

log = void 0;

run = void 0;

log = new (require("log"))("debug");

auth = require("./src/qqauth");

api = require("./src/qqapi");

QQBot = require("./src/qqbot");

defaults = require("./src/defaults");

config = require("./config");

KEY_COOKIES = "qq-cookies";

KEY_AUTH = "qq-auth";

get_tokens = function(isneedlogin, options, callback) {
  var auth_info, cookies;
  auth_info = void 0;
  cookies = void 0;
  auth_info = void 0;
  cookies = void 0;
  if (isneedlogin) {
    return auth.login(options, function(cookies, auth_info) {
      defaults.data(KEY_COOKIES, cookies);
      defaults.data(KEY_AUTH, auth_info);
      defaults.save();
      return callback(cookies, auth_info);
    });
  } else {
    cookies = defaults.data(KEY_COOKIES);
    auth_info = defaults.data(KEY_AUTH);
    log.info("skip login");
    return callback(cookies, auth_info);
  }
};

run = function() {
  "start qqbot...";
  var isneedlogin, params;
  isneedlogin = void 0;
  params = void 0;
  isneedlogin = void 0;
  params = void 0;
  params = process.argv.slice(-1)[0] || "";
  isneedlogin = params.trim() !== "nologin";
  return get_tokens(isneedlogin, config, function(cookies, auth_info) {
    var bot;
    bot = void 0;
    bot = void 0;
    bot = new QQBot(cookies, auth_info, config);
    bot.on_die(function() {
      if (isneedlogin) {
        return run();
      }
    });
    return bot.update_all_members(function(ret) {
      if (!ret) {
        log.error("获取信息失败");
        process.exit(1);
      }
      log.info("Entering runloop, Enjoy!");
      bot.listen_group("2015-SM2-19th全国学生群", function(_group, error) {
        var group;
        group = void 0;
        log.info("enter long poll mode, have fun");
        bot.runloop();
        group = _group;
        return group.on_message(function(content, send, robot, message) {
          log.info("received", content);
          return send("...");
        });
      });
      bot.listen_group("机器人测试", function(_group, error) {
        var group;
        group = void 0;
        log.info("enter long poll mode, have fun");
        bot.runloop();
        group = _group;
        return group.on_message(function(content, send, robot, message) {
          log.info("received", content);
          return send("mom");
        });
      });
    });
  });
};

run();

