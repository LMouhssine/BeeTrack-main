package com.rucheconnectee.controller;

import com.rucheconnectee.model.RuchesNew;
import com.rucheconnectee.service.RuchesNewService;
import com.rucheconnectee.service.RuchersNewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/RuchesNew")
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "false", matchIfMissing = true)
public class RuchesNewController {

    @Autowired
    private RuchesNewService service;

    @Autowired
    private RuchersNewService ruchersService;

    // Liste
    @GetMapping
    public String list(Model model) {
        List<RuchesNew> list = service.findAll();
        model.addAttribute("items", list);
        model.addAttribute("currentPage", "ruchesnew");
        model.addAttribute("pageTitle", "RuchesNew");
        model.addAttribute("pageSubtitle", "Gestion simple des ruches");
        return "ruchesnew/list";
    }

    // Formulaire création
    @GetMapping("/nouvelle")
    public String createForm(Model model) {
        model.addAttribute("item", new RuchesNew());
        model.addAttribute("ruchers", ruchersService.findAll());
        model.addAttribute("currentPage", "ruchesnew");
        model.addAttribute("pageTitle", "Nouvelle ruche");
        return "ruchesnew/form";
    }

    // Création
    @PostMapping
    public String create(@ModelAttribute("item") RuchesNew ruche,
                         RedirectAttributes ra) {
        service.create(ruche);
        ra.addFlashAttribute("message", "Ruche créée avec succès");
        ra.addFlashAttribute("messageType", "success");
        return "redirect:/RuchesNew";
    }

    // Formulaire édition
    @GetMapping("/{id}/editer")
    public String editForm(@PathVariable String id, Model model, RedirectAttributes ra) {
        RuchesNew existing = service.findById(id);
        if (existing == null) {
            ra.addFlashAttribute("error", "Ruche introuvable");
            return "redirect:/RuchesNew";
        }
        model.addAttribute("item", existing);
        model.addAttribute("ruchers", ruchersService.findAll());
        model.addAttribute("currentPage", "ruchesnew");
        model.addAttribute("pageTitle", "Modifier ruche");
        return "ruchesnew/form";
    }

    // Mise à jour
    @PostMapping("/{id}")
    public String update(@PathVariable String id,
                         @ModelAttribute("item") RuchesNew ruche,
                         RedirectAttributes ra) {
        service.update(id, ruche);
        ra.addFlashAttribute("message", "Ruche mise à jour");
        ra.addFlashAttribute("messageType", "success");
        return "redirect:/RuchesNew";
    }

    // Suppression
    @PostMapping("/{id}/supprimer")
    public String delete(@PathVariable String id, RedirectAttributes ra) {
        service.delete(id);
        ra.addFlashAttribute("message", "Ruche supprimée");
        return "redirect:/RuchesNew";
    }

    // Affichage d'un élément
    @GetMapping("/{id}")
    public String show(@PathVariable String id, Model model, RedirectAttributes ra) {
        RuchesNew existing = service.findById(id);
        if (existing == null) {
            ra.addFlashAttribute("error", "Ruche introuvable");
            return "redirect:/RuchesNew";
        }
        model.addAttribute("item", existing);
        model.addAttribute("currentPage", "ruchesnew");
        model.addAttribute("pageTitle", "Détail ruche");
        return "ruchesnew/detail";
    }
}


