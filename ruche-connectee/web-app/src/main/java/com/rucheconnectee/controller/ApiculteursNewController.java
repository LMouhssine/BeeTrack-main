package com.rucheconnectee.controller;

import com.rucheconnectee.model.ApiculteursNew;
import com.rucheconnectee.service.ApiculteursNewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.security.access.prepost.PreAuthorize;

import java.util.List;

@Controller
@RequestMapping("/ApiculteursNew")
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "false", matchIfMissing = true)
public class ApiculteursNewController {

    @Autowired(required = false)
    private ApiculteursNewService service;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public String list(Model model) {
        List<ApiculteursNew> items = service.findAll();
        model.addAttribute("items", items);
        model.addAttribute("currentPage", "apiculteursnew");
        model.addAttribute("pageTitle", "ApiculteursNew");
        return "apiculteursnew/list";
    }

    @GetMapping("/nouveau")
    @PreAuthorize("hasRole('ADMIN')")
    public String createForm(Model model) {
        model.addAttribute("item", new ApiculteursNew());
        model.addAttribute("currentPage", "apiculteursnew");
        model.addAttribute("pageTitle", "Nouvel apiculteur");
        return "apiculteursnew/form";
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public String create(@ModelAttribute("item") ApiculteursNew item, RedirectAttributes ra) {
        service.create(item);
        ra.addFlashAttribute("message", "Apiculteur créé (Auth + DB)");
        ra.addFlashAttribute("messageType", "success");
        return "redirect:/ApiculteursNew";
    }

    @GetMapping("/{id}/editer")
    @PreAuthorize("hasRole('ADMIN')")
    public String editForm(@PathVariable String id, Model model, RedirectAttributes ra) {
        ApiculteursNew existing = service.findById(id);
        if (existing == null) {
            ra.addFlashAttribute("error", "Apiculteur introuvable");
            return "redirect:/ApiculteursNew";
        }
        model.addAttribute("item", existing);
        model.addAttribute("currentPage", "apiculteursnew");
        model.addAttribute("pageTitle", "Modifier apiculteur");
        return "apiculteursnew/form";
    }

    @PostMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public String update(@PathVariable String id, @ModelAttribute("item") ApiculteursNew item, RedirectAttributes ra) {
        service.update(id, item);
        ra.addFlashAttribute("message", "Apiculteur mis à jour");
        ra.addFlashAttribute("messageType", "success");
        return "redirect:/ApiculteursNew";
    }

    @PostMapping("/{id}/supprimer")
    @PreAuthorize("hasRole('ADMIN')")
    public String delete(@PathVariable String id, RedirectAttributes ra) {
        service.delete(id);
        ra.addFlashAttribute("message", "Apiculteur supprimé (Auth + DB)");
        return "redirect:/ApiculteursNew";
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public String detail(@PathVariable String id, Model model, RedirectAttributes ra) {
        ApiculteursNew existing = service.findById(id);
        if (existing == null) {
            ra.addFlashAttribute("error", "Apiculteur introuvable");
            return "redirect:/ApiculteursNew";
        }
        model.addAttribute("item", existing);
        model.addAttribute("currentPage", "apiculteursnew");
        model.addAttribute("pageTitle", "Détail apiculteur");
        return "apiculteursnew/detail";
    }
}

