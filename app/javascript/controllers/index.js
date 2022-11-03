// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import Filters__DatePickerController from "./filters/date_picker_controller.js"
application.register("filters--date-picker", Filters__DatePickerController)

import Filters__FieldController from "./filters/field_controller.js"
application.register("filters--field", Filters__FieldController)

import FiltersController from "./filters_controller.js"
application.register("filters", FiltersController)

import MaskedContentController from "./masked_content_controller.js"
application.register("masked-content", MaskedContentController)

import SidebarController from "./sidebar_controller.js"
application.register("sidebar", SidebarController)

import SignUpController from "./sign_up_controller.js"
application.register("sign-up", SignUpController)

import SipTrunksController from "./sip_trunks_controller.js"
application.register("sip-trunks", SipTrunksController)

import SmsGatewayChannelGroupsController from "./sms_gateway_channel_groups_controller.js"
application.register("sms-gateway-channel-groups", SmsGatewayChannelGroupsController)
