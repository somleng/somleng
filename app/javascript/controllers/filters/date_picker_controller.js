import { Controller } from "stimulus"
import $ from "jquery";
import "daterangepicker/daterangepicker.js"
import moment from "moment"

const FORMAT = "DD/MM/YYYY"

export default class extends Controller {
  static targets = ["dateRangePicker", "fromDate", "toDate"]

  connect() {
    $(this.dateRangePickerTarget).daterangepicker({
      autoApply: true,
      opens: 'left',
      locale: {
        format: FORMAT,
        separator: " to ",
        cancelLabel: 'Reset'
      },
      ranges: {
        'Today': [moment(), moment()],
        'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
        'Last 7 Days': [moment().subtract(6, 'days'), moment()],
        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
        'This Month': [moment().startOf('month'), moment().endOf('month')],
        'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
      }
    })

    // after calling daterangepicker function to prevent closing parent Bootstrap dropdown
    $("div.daterangepicker").on("click", (e) => {
      e.stopPropagation()
    })

    if(this.validateDates(this.fromDateTarget.value, this.toDateTarget.value)) {
      let pickerData = $(this.dateRangePickerTarget).data("daterangepicker")

      pickerData.setStartDate(this.fromDateTarget.value)
      pickerData.setEndDate(this.toDateTarget.value)
    } else {
      this.dateRangePickerTarget.value = ""
    }

    $(this.dateRangePickerTarget).on("apply.daterangepicker", (event, picker) => {
      this.fromDateTarget.value = picker.startDate.format(FORMAT)
      this.toDateTarget.value   = picker.endDate.format(FORMAT)
    })

    $(this.dateRangePickerTarget).on("cancel.daterangepicker", () => {
      this.dateRangePickerTarget.value = ""

      $(this.fromDateTarget).remove()
      $(this.toDateTarget).remove()
    })
  }

  validateDates(fromDate, toDate){
    return moment(fromDate, FORMAT).isValid() && moment(toDate, FORMAT).isValid()
  }
}
