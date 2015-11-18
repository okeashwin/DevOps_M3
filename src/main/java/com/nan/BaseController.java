package com.nan;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import redis.clients.jedis.Jedis;

import java.util.Map;

@Controller
public class BaseController {

    public static final String FEATURES_MAP_KEY = "features";
    public static final String FLAG_OFF = "off";
    public static final String FLAG_ON = "on";
    public static final String REDIS_HOST = "localhost";
    public static final int REDIS_PORT = 6379;

    @RequestMapping("/feature/set")
    public ModelAndView setFlag(
            @RequestParam(value = "name", required = true) String name,
            @RequestParam(value = "flag", required = true) String flag) {
        ModelAndView mv = new ModelAndView("feature_set");
        flag = FLAG_OFF.equalsIgnoreCase(flag) ? FLAG_OFF : FLAG_ON;
        Jedis jedis = new Jedis(REDIS_HOST, REDIS_PORT);
        jedis.hset(FEATURES_MAP_KEY, name, flag);
        String message = "Successfully switched " + flag + " feature " + name;
        mv.addObject("message", message);
        return mv;
    }

    @RequestMapping("/feature/get")
    public ModelAndView getFlag(
            @RequestParam(value = "name", required = true) String name) {
        ModelAndView mv = new ModelAndView("feature_get");
        Jedis jedis = new Jedis(REDIS_HOST, REDIS_PORT);
        String flag = jedis.hget(FEATURES_MAP_KEY, name);
        String message;
        if (flag == null) {
            message = "Cannot find feature with name" + name;

        } else {
            message = "Feature " + name + " is " + flag;
        }

        mv.addObject("message", message);
        return mv;
    }

    @RequestMapping("/feature/list")
    public ModelAndView list() {
        Jedis jedis = new Jedis(REDIS_HOST, REDIS_PORT);
        Map<String, String> features = jedis.hgetAll(FEATURES_MAP_KEY);
        ModelAndView mv = new ModelAndView("feature_list");
        mv.addObject("features", features);
        return mv;
    }
}