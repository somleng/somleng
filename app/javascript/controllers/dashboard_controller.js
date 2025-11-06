import { Controller } from "@hotwired/stimulus";
import * as bootstrap from "bootstrap";
import * as coreui from "@coreui/coreui";

// Connects to data-controller="dashboard"
export default class extends Controller {
  connect() {
    this.initializeAll();
  }

  initializeAll() {
    this.initializeBootstrap();
    this.initializeCoreUI();
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
}
