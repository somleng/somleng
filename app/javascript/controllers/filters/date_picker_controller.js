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
        onSelect: ({date, formattedDate}) => {
          if(formattedDate.length == 1) {
            let selectedDate = date[0];
            let minDate = new Date(selectedDate);
            let maxDate = new Date(selectedDate);
            minDate.setMonth(selectedDate.getMonth() - 3);
            maxDate.setMonth(selectedDate.getMonth() + 3);
            picker.update({minDate: minDate, maxDate: maxDate});

            formattedDate.push(formattedDate[0]);
          }

          const [fromDate, toDate] = formattedDate;
          this.fromDateTarget.value = fromDate;
          this.toDateTarget.value   = toDate;
        }
      }
    );

    // after calling AirDatepicker function to prevent closing parent Bootstrap dropdown
    picker.$datepicker.addEventListener("click", (e) => e.stopPropagation());
  }
}
