package com.nan;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import redis.clients.jedis.Jedis;

@Controller
public class BaseController {

    @RequestMapping("/feature/set")
    public ModelAndView setFlag(
            @RequestParam(value = "name", required = true) String name,
            @RequestParam(value = "flag", required = true) String flag) {
        ModelAndView mv = new ModelAndView("feature_set");
        flag = "off".equalsIgnoreCase(flag) ? "off" : "on";
        Jedis jedis = new Jedis("localhost", 6379);
        jedis.set("feature_" + name, flag);
        String message = "Successfully switched " + flag + " feature " + name;
        mv.addObject("message", message);
        return mv;
    }

    @RequestMapping("/feature/get")
    public ModelAndView getFlag(
            @RequestParam(value = "name", required = true) String name) {
        ModelAndView mv = new ModelAndView("feature_get");
        Jedis jedis = new Jedis("localhost", 6379);
        String flag = jedis.get("feature_" + name);
        String message;
        if (flag == null) {
            message = "Cannot find feature with name" + name;

        } else {
            message = "Feature " + name + " is " + flag;
        }

        mv.addObject("message", message);
        return mv;
    }
}