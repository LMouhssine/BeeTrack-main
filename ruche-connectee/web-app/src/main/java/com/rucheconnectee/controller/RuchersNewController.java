package com.rucheconnectee.controller;

import com.rucheconnectee.model.RuchersNew;
import com.rucheconnectee.service.RuchersNewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/RuchersNew")
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "false", matchIfMissing = true)
public class RuchersNewController {

    @Autowired
    private RuchersNewService service;

    @GetMapping
    public String list(Model model) {
        List<RuchersNew> items = service.findAll();
        model.addAttribute("items", items);
        model.addAttribute("currentPage", "ruchersnew");
        model.addAttribute("pageTitle", "RuchersNew");
        return "ruchersnew/list";
    }

    @GetMapping("/nouveau")
    public String createForm(Model model) {
        model.addAttribute("item", new RuchersNew());
        model.addAttribute("currentPage", "ruchersnew");
        model.addAttribute("pageTitle", "Nouveau rucher");
        return "ruchersnew/form";
    }

    @PostMapping
    public String create(@ModelAttribute("item") RuchersNew item, RedirectAttributes ra) {
        service.create(item);
        ra.addFlashAttribute("message", "Rucher créé");
        ra.addFlashAttribute("messageType", "success");
        return "redirect:/RuchersNew";
    }

    @GetMapping("/{id}/editer")
    public String editForm(@PathVariable String id, Model model, RedirectAttributes ra) {
        RuchersNew existing = service.findById(id);
        if (existing == null) {
            ra.addFlashAttribute("error", "Rucher introuvable");
            return "redirect:/RuchersNew";
        }
        model.addAttribute("item", existing);
        model.addAttribute("currentPage", "ruchersnew");
        model.addAttribute("pageTitle", "Modifier rucher");
        return "ruchersnew/form";
    }

    @PostMapping("/{id}")
    public String update(@PathVariable String id, @ModelAttribute("item") RuchersNew item, RedirectAttributes ra) {
        service.update(id, item);
        ra.addFlashAttribute("message", "Rucher mis à jour");
        ra.addFlashAttribute("messageType", "success");
        return "redirect:/RuchersNew";
    }

    @PostMapping("/{id}/supprimer")
    public String delete(@PathVariable String id, RedirectAttributes ra) {
        service.delete(id);
        ra.addFlashAttribute("message", "Rucher supprimé");
        return "redirect:/RuchersNew";
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable String id, Model model, RedirectAttributes ra) {
        RuchersNew existing = service.findById(id);
        if (existing == null) {
            ra.addFlashAttribute("error", "Rucher introuvable");
            return "redirect:/RuchersNew";
        }
        model.addAttribute("item", existing);
        model.addAttribute("currentPage", "ruchersnew");
        model.addAttribute("pageTitle", "Détail rucher");
        return "ruchersnew/detail";
    }
}







