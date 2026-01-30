import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

// Connects to data-controller="enhanced-select"
export default class extends Controller {
  connect() {
    if (this.element.tomselect) return;

    const defaultPlugins = [];

    // Read options from data attribute, default to empty object
    const options = this.element.dataset.enhancedSelectOptions
      ? JSON.parse(this.element.dataset.enhancedSelectOptions)
      : {};

    // Map generic options to library-specific plugin configuration
    const plugins = [...defaultPlugins];
    if (options.removeItemButton) {
      plugins.push("remove_button"); // TomSelect plugin name
    }

    this.element.tomselect = new TomSelect(this.element, {
      plugins: plugins,
      ...options,
    });

    this.element.addEventListener("options-changed", () => {
      const ts = this.element.tomselect;
      ts.clear();
      ts.clearOptions();
      Array.from(this.element.options).forEach((opt) =>
        ts.addOption({ value: opt.value, text: opt.text })
      );
      ts.refreshOptions(false);
      ts.setValue(""); // reset selection
    });

    this.element.addEventListener("value-set", (event) => {
      const value = event.detail.value;
      const ts = this.element.tomselect;
      if (value) {
        ts.setValue(value, true); // true = silent (don’t trigger change)
      } else {
        ts.clear(true);
      }
    });

    this._observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.attributeName === "disabled") {
          const ts = this.element.tomselect;
          if (this.element.disabled) {
            if (!ts.isDisabled) {
              ts.disable();
            }
          } else {
            ts.enable();
          }
        }
      });
    });

    this._observer.observe(this.element, { attributes: true });
  }
}
