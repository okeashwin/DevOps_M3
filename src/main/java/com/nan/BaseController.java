package com.nan;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import java.util.Map;

@Controller
public class BaseController {

    private FeatureImpl featureImpl = new FeatureImpl();

    @RequestMapping("/feature/set")
    public ModelAndView setFlag(
            @RequestParam(value = "name", required = true) String name,
            @RequestParam(value = "flag", required = true) String flag) {
        String message = featureImpl.setFlag(name, flag);
        ModelAndView mv = new ModelAndView("feature_set");
        mv.addObject("message", message);
        return mv;
    }

    @RequestMapping("/feature/get")
    public ModelAndView getFlag(
            @RequestParam(value = "name", required = true) String name) {
        String message = featureImpl.getFlag(name);
        ModelAndView mv = new ModelAndView("feature_get");
        mv.addObject("message", message);
        return mv;
    }

    @RequestMapping("/feature/list")
    public ModelAndView list() {
        Map<String, String> features = featureImpl.list();
        ModelAndView mv = new ModelAndView("feature_list");
        mv.addObject("features", features);
        return mv;
    }
}