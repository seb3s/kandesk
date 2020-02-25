import $ from "cash-dom";
import {Socket} from "phoenix";
import LiveSocket from "phoenix_live_view";
import MicroModal from "../vendor/micromodal";
import Popper from "../vendor/popper";

let webapp = (function (webapp) {

// --------------------------------------------------------------------------------------
// live_view hooks
// --------------------------------------------------------------------------------------
let phx_hooks = {}


// --------------------------------------------------------------------------------------
// live_view live_socket
// --------------------------------------------------------------------------------------
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
webapp.live_socket = new LiveSocket("/live", Socket, {
    params: {_csrf_token: csrfToken},
    hooks: phx_hooks});
webapp.live_socket.connect();


// --------------------------------------------------------------------------------------
// webapp initialization
// --------------------------------------------------------------------------------------
webapp.init = function() {

}


return webapp;

}(webapp || {}));

window.webapp = webapp;
