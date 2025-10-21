import { Controller } from "@hotwired/stimulus";

import * as bootstrap from "bootstrap";
import * as coreui from "@coreui/coreui";
import Choices from "choices.js";

// Connects to data-controller="dashboard"
export default class extends Controller {
  connect() {
    [].slice
      .call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
      .map(function (element) {
        return new bootstrap.Tooltip(element);
      });

    [].slice
      .call(document.querySelectorAll('[data-bs-toggle="popover"]'))
      .map(function (element) {
        return new bootstrap.Popover(element);
      });

    [].slice
      .call(document.querySelectorAll('[data-coreui="navigation"]'))
      .map(function (element) {
        return coreui.Navigation.getOrCreateInstance(element);
      });

    [].slice
      .call(document.querySelectorAll("time[data-behavior~=local-time]"))
      .map(function (element) {
        element.textContent = new Intl.DateTimeFormat(navigator.language, {
          dateStyle: "medium",
          timeStyle: "long",
        }).format(new Date(element.textContent));
      });

    [].slice
      .call(document.querySelectorAll(".sidebar"))
      .map(function (element) {
        return coreui.Sidebar.getOrCreateInstance(element);
      });

    [].slice
      .call(document.querySelectorAll("[data-behavior~=choices-input]"))
      .map(function (element) {
        const instance = new Choices(
          element,
          JSON.parse(element.dataset.choicesOptions || "{}")
        );

        const wrapper = element.closest(".choices");

        if (element.classList.contains("is-invalid")) {
          wrapper.classList.add("is-invalid");
        }

        return instance;
      });
  }
}
