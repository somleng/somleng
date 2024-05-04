import { Controller } from "@hotwired/stimulus";

import AirDatepicker from "air-datepicker";
import localeEn from "air-datepicker/locale/en";

export default class extends Controller {
  static targets = ["dateRangePicker", "fromDate", "toDate"];

  connect() {
    const datePickerOptions = {
      container: "#filters",
      locale: localeEn,
      range: true,
      buttons: ["clear"],
      toggleSelected: false,
      multipleDatesSeparator: "-",
      autoClose: true,
      onSelect: ({ date, formattedDate }) => {
        if (formattedDate.length == 0) return;
        if (formattedDate.length == 1) {
          if ("maxDateRangeMonths" in this.dateRangePickerTarget.dataset) {
            const maxDateRangeMonths = parseInt(
              this.dateRangePickerTarget.dataset.maxDateRangeMonths
            );
            let selectedDate = date[0];
            let minDate = new Date(selectedDate);
            let maxDate = new Date(selectedDate);
            minDate.setMonth(selectedDate.getMonth() - maxDateRangeMonths);
            maxDate.setMonth(selectedDate.getMonth() + maxDateRangeMonths);
            picker.update({ minDate: minDate, maxDate: maxDate });
          }

          formattedDate.push(formattedDate[0]);
        }

        const [fromDate, toDate] = formattedDate;
        this.fromDateTarget.value = new Date(fromDate).toISOString();
        this.toDateTarget.value = new Date(toDate).toISOString();
      },
    };

    if (this.fromDateTarget.value && this.toDateTarget.value) {
      datePickerOptions.selectedDates = [
        this.fromDateTarget.value,
        this.toDateTarget.value,
      ];
    }

    const picker = new AirDatepicker(
      this.dateRangePickerTarget,
      datePickerOptions
    );

    // after calling AirDatepicker function to prevent closing parent Bootstrap dropdown
    picker.$datepicker.addEventListener("click", (e) => e.stopPropagation());
  }
}
