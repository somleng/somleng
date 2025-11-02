import { Controller } from "@hotwired/stimulus";
import * as bootstrap from "bootstrap";
import * as coreui from "@coreui/coreui";
import Choices from "choices.js";

// Connects to data-controller="dashboard"
export default class extends Controller {
  connect() {
    this.initializeAll();
  }

  initializeAll() {
    this.initializeBootstrap();
    this.initializeCoreUI();
    this.initializeTime();
  }

  initializeBootstrap() {
    [].slice
      .call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
      .map((el) => new bootstrap.Tooltip(el));
    [].slice
      .call(document.querySelectorAll('[data-bs-toggle="popover"]'))
      .map((el) => new bootstrap.Popover(el));
  }

  initializeCoreUI() {
    [].slice
      .call(document.querySelectorAll('[data-coreui="navigation"]'))
      .map((el) => coreui.Navigation.getOrCreateInstance(el));
    [].slice
      .call(document.querySelectorAll(".sidebar"))
      .map((el) => coreui.Sidebar.getOrCreateInstance(el));
  }

  initializeTime() {
    [].slice
      .call(document.querySelectorAll("time[data-behavior~=local-time]"))
      .map((el) => {
        el.textContent = new Intl.DateTimeFormat(navigator.language, {
          dateStyle: "medium",
          timeStyle: "long",
        }).format(new Date(el.textContent));
      });
  }
}
