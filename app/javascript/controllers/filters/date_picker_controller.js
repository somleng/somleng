import { Controller } from "@hotwired/stimulus"
import moment from "moment"

import AirDatepicker from 'air-datepicker';
import localeEn from 'air-datepicker/locale/en';

export default class extends Controller {
  static targets = ["dateRangePicker", "fromDate", "toDate"]

  connect() {
    const picker = new AirDatepicker(
      this.dateRangePickerTarget,
      {
        container: "#filters",
        locale: localeEn,
        range: true,
        buttons: ["clear"],
        toggleSelected: false,
        multipleDatesSeparator: "-",
        autoClose: true,
        dateFormat: "dd/MM/yyyy",
        selectedDates: [
          moment(this.fromDateTarget.value, "DD/MM/YYYY"),
          moment(this.toDateTarget.value, "DD/MM/YYYY")
        ],
        onSelect: ({formattedDate}) => {
          if (formattedDate.length == 1) { return; }

          const [fromDate, toDate] = formattedDate;
          this.fromDateTarget.value = fromDate
          this.toDateTarget.value   = toDate
        }
      }
    );

    // after calling AirDatepicker function to prevent closing parent Bootstrap dropdown
    picker.$datepicker.addEventListener("click", (e) => e.stopPropagation());
  }
}
